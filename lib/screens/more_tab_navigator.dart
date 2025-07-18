import 'package:flutter/material.dart';
import 'more.dart';
import 'lost_and_found.dart';
import 'item_detail.dart';
import '../models/lost_and_found.dart';

class MoreTabNavigator extends StatelessWidget {
  const MoreTabNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      initialRoute: '/',
      onGenerateRoute: (RouteSettings settings) {
        WidgetBuilder builder;
        switch (settings.name) {
          case '/':
          // The initial page is your list of more options
            builder = (BuildContext _) => const MorePage();
            break;
          case '/lostAndFound':
          // This is the route for the Lost & Found screen
            builder = (BuildContext _) => const LostAndFoundScreen();
            break;
          case '/itemDetail':
          // This handles navigating to the detail screen and passing the item data
            final item = settings.arguments as FoundItem;
            builder = (BuildContext _) => ItemDetailScreen(item: item);
            break;
          default:
            throw Exception('Invalid route: ${settings.name}');
        }
        return MaterialPageRoute(builder: builder, settings: settings);
      },
    );
  }
}