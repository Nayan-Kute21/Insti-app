import 'package:flutter/material.dart';
import '../services/auth_service.dart'; // Ensure you have this import
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
  UserRole? _userRole;
  bool _isLoading = true; // Start in a loading state

  @override
  void initState() {
    super.initState();
    _checkAuthenticationStatus();
  }

  // Check if a JWT token already exists
  Future<void> _checkAuthenticationStatus() async {
    final authService = AuthService();
    final isAuthenticated = await authService.isAuthenticated();
    if (mounted) {
      setState(() {
        if (isAuthenticated) {
          _userRole = UserRole.authenticated;
        }
        _isLoading = false;
      });
    }
  }

  void _loginAsAuthenticatedUser() {
    setState(() {
      _userRole = UserRole.authenticated;
    });
  }

  void _loginAsGuest() {
    setState(() {
      _userRole = UserRole.guest;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator while checking auth status
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_userRole != null) {
      // If the user has a role (logged in or guest), show the dashboard
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