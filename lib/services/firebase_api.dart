import 'dart:convert';
import 'dart:io'; // Import for File
import 'package:http/http.dart' as http; // Import for HTTP requests
import 'package:path_provider/path_provider.dart'; // Import for file paths
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:insti_app/screens/notifications_screen.dart';


// --- HELPER FUNCTION TO PREPARE THE BIG PICTURE STYLE ---
Future<BigPictureStyleInformation?> _getBigPictureStyleInformation(String? imageUrl) async {
  if (imageUrl == null || imageUrl.isEmpty) {
    return null;
  }
  try {
    // 1. Download the image
    final http.Response response = await http.get(Uri.parse(imageUrl));

    // 2. Get a temporary directory to save the file
    final Directory tempDir = await getTemporaryDirectory();
    final String tempPath = tempDir.path;
    final File file = File('$tempPath/big_picture.jpg');

    // 3. Write the image data to the file
    await file.writeAsBytes(response.bodyBytes);

    // 4. Create the style information
    return BigPictureStyleInformation(
      FilePathAndroidBitmap(file.path),
      hideExpandedLargeIcon: true,
      contentTitle: null, // Title is already shown, no need to repeat
      summaryText: null,  // Body is already shown, no need to repeat
    );
  } catch (e) {
    print("Error downloading or creating big picture style: $e");
    return null;
  }
}


@pragma('vm:entry-point')
Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print('--- Background Message Received ---');
  print('Payload: ${message.data}');

  final String? title = message.data['title'];
  final String? body = message.data['body'];
  final String? imageUrl = message.data['image'];

  if (title == null || body == null) return;

  // Get the big picture style
  final styleInformation = await _getBigPictureStyleInformation(imageUrl);

  final localNotifications = FlutterLocalNotificationsPlugin();
  const androidChannel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  await localNotifications
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(androidChannel);

  // Show the notification with the new style
  localNotifications.show(
    DateTime.now().millisecondsSinceEpoch.toUnsigned(31),
    title,
    body,
    NotificationDetails(
      android: AndroidNotificationDetails(
        androidChannel.id,
        androidChannel.name,
        channelDescription: androidChannel.description,
        icon: '@drawable/ic_notification',
        importance: Importance.high,
        styleInformation: styleInformation, // <-- ADD THE STYLE HERE
      ),
    ),
    payload: jsonEncode(message.toMap()),
  );
}

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _secureStorage = const FlutterSecureStorage();
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final _androidChannel = const AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );
  final _localNotifications = FlutterLocalNotificationsPlugin();

  void handleMessage(RemoteMessage? message) {
    if (message == null) return;
    navigatorKey.currentState?.pushNamed(
      NotificationsScreen.route,
      arguments: message,
    );
  }

  Future<void> initLocalNotifications() async {
    const android = AndroidInitializationSettings('@drawable/ic_notification');
    const settings = InitializationSettings(android: android);
    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (payload) {
        final message = RemoteMessage.fromMap(jsonDecode(payload.payload!));
        handleMessage(message);
      },
    );
    _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
    final platform = _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await platform?.createNotificationChannel(_androidChannel);
  }

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    final fcmToken = await _firebaseMessaging.getToken();
    print('====================================');
    print('FCM Token: $fcmToken');
    print('====================================');
    await _registerToken(fcmToken);
    await initPushNotifications();
    await initLocalNotifications();
  }

  Future<void> initPushNotifications() async {
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    FirebaseMessaging.onMessage.listen((message) async { // Make this listener async
      print('--- Foreground Message Received ---');
      print('Payload: ${message.data}');
      final String? title = message.data['title'];
      final String? body = message.data['body'];
      final String? imageUrl = message.data['image'];

      if (title == null || body == null) return;

      // Get the big picture style for foreground too
      final styleInformation = await _getBigPictureStyleInformation(imageUrl);

      _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch.toUnsigned(31),
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            icon: '@drawable/ic_notification',
            styleInformation: styleInformation, // <-- ADD THE STYLE HERE
          ),
        ),
        payload: jsonEncode(message.toMap()),
      );
    });
  }

  Future<void> _registerToken(String? token) async {
    if (token == null) return;
    final jwt = await _secureStorage.read(key: 'jwt');
    if (jwt == null) return;
    try {
      await http.post(
        Uri.parse('https://backend.instiapp.tech/api/notifications/register-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwt',
        },
        body: jsonEncode({'token': token}),
      );
    } catch (e) {
      print('Error registering FCM token: $e');
    }
  }
}