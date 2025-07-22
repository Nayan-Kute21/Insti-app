// lib/screens/profile_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:convert';

import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? name, email, userName, userType, phone, avatarUrl;
  File? _avatarFile;
  bool _loading = true;
  bool _updating = false;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() => _loading = true);
    final token = await AuthService().getToken();
    final baseUrl = AuthService.baseUrl;
    final res = await http.get(
      Uri.parse('$baseUrl/api/users/getUserDetailed'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      setState(() {
        name = data['name'];
        email = data['email'];
        userName = data['userName'];
        userType = data['userTypeName'];
        phone = data['phoneNumber'];
        avatarUrl = data['avatarUrl'];
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
      // Handle error
    }
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _avatarFile = File(picked.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _updating = true);

    final token = await AuthService().getToken();
    final baseUrl = AuthService.baseUrl;
    final uri = Uri.parse('$baseUrl/api/users/updateUserProfile');
    final request = http.MultipartRequest('PUT', uri);
    request.headers['Authorization'] = 'Bearer $token';

    // Add user JSON as a part
    final userMap = {
      'phoneNumber': phone ?? '',
      'avatarUrl': '', // backend will set this if avatar is uploaded
    };
    request.files.add(http.MultipartFile.fromString(
      'user',
      json.encode(userMap),
      contentType: MediaType('application', 'json'),
    ));

    // Add avatar if selected
    if (_avatarFile != null) {
      final mimeType = lookupMimeType(_avatarFile!.path) ?? 'image/jpeg';
      final fileName = _avatarFile!.path.split('/').last;
      request.files.add(await http.MultipartFile.fromPath(
        'avatar',
        _avatarFile!.path,
        contentType: MediaType.parse(mimeType),
        filename: fileName,
      ));
    }

    final response = await request.send();
    setState(() => _updating = false);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated!')),
      );
      _fetchProfile();
    } else {
      final respStr = await response.stream.bytesToString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update failed: $respStr')),
      );
    }
  }

  Future<void> _deleteUser() async {
    final token = await AuthService().getToken();
    final baseUrl = AuthService.baseUrl;
    final res = await http.delete(
      Uri.parse('$baseUrl/api/users/delete'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200) {
      // Log out and navigate away
      await AuthService().signOut();
      Navigator.of(context).pushReplacementNamed('/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete failed: ${res.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: _avatarFile != null
                          ? FileImage(_avatarFile!)
                          : (avatarUrl != null && avatarUrl!.isNotEmpty
                          ? NetworkImage(avatarUrl!)
                          : null) as ImageProvider<Object>?,
                      child: (avatarUrl == null || avatarUrl!.isEmpty) && _avatarFile == null
                          ? const Icon(Icons.person, size: 50)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: _pickAvatar,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                initialValue: name,
                decoration: const InputDecoration(labelText: 'Name'),
                enabled: false,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: userName,
                decoration: const InputDecoration(labelText: 'Username'),
                enabled: false,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: email,
                decoration: const InputDecoration(labelText: 'Email'),
                enabled: false,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: userType,
                decoration: const InputDecoration(labelText: 'User Type'),
                enabled: false,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: phone,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                onSaved: (val) => phone = val,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _updating ? null : _updateProfile,
                child: _updating
                    ? const CircularProgressIndicator()
                    : const Text('Update Profile'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _deleteUser,
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}