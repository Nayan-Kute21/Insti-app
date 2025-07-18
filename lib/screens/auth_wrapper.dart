import 'package:flutter/material.dart';
import '../dashboard.dart';
import 'login_screen.dart';

// Define user roles
enum UserRole { guest, authenticated }

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  // Use a nullable UserRole to track the login state and type
  UserRole? _userRole;

  // Set the role to authenticated
  void _loginAsAuthenticatedUser() {
    setState(() {
      _userRole = UserRole.authenticated;
    });
  }

  // Set the role to guest
  void _loginAsGuest() {
    setState(() {
      _userRole = UserRole.guest;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_userRole != null) {
      // If the user has a role (logged in or guest), show the dashboard
      // and pass the role to it.
      return DashboardPage(userRole: _userRole!);
    } else {
      // Otherwise, show the login screen
      return LoginScreen(
        onLoginSuccess: _loginAsAuthenticatedUser,
        onGuestLogin: _loginAsGuest,
      );
    }
  }
}