import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart'; // Import the new service

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  final VoidCallback onGuestLogin;

  const LoginScreen({
    super.key,
    required this.onLoginSuccess,
    required this.onGuestLogin,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
    });

    final success = await _authService.signInWithOAuth();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (success) {
        // If login is successful, call the callback to navigate away.
        widget.onLoginSuccess();
      } else {
        // Show an error message if login fails.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF5),
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // ... (your existing decorative elements are unchanged)
            Positioned(
              top: 162,
              left: 118,
              child: Container(
                width: 72,
                height: 72,
                decoration: const ShapeDecoration(
                  color: Color(0xFF97DA4F),
                  shape: OvalBorder(),
                ),
              ),
            ),
            Positioned(
              top: 265,
              right: -10,
              child: Transform.rotate(
                angle: 3.14,
                child: Text(
                  '👋',
                  style: GoogleFonts.bricolageGrotesque(
                    fontSize: 54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 90),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Hey You!\n',
                          style: GoogleFonts.bricolageGrotesque(
                              fontWeight: FontWeight.w300),
                        ),
                        TextSpan(
                          text: 'Glad',
                          style: GoogleFonts.bricolageGrotesque(
                              fontWeight: FontWeight.w700),
                        ),
                        TextSpan(
                          text: ' to see you ',
                          style: GoogleFonts.bricolageGrotesque(
                              fontWeight: FontWeight.w300),
                        ),
                        TextSpan(
                          text: 'here',
                          style: GoogleFonts.bricolageGrotesque(
                              fontWeight: FontWeight.w700),
                        ),
                        TextSpan(
                          text: '!',
                          style: GoogleFonts.bricolageGrotesque(
                              fontWeight: FontWeight.w300),
                        ),
                      ],
                    ),
                    style: const TextStyle(
                      color: Color(0xFF1E47F7),
                      fontSize: 64,
                      height: 1.12,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Login with Your IIT Jodhpur official email for the best experience',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF4262C8),
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E47F7),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                        elevation: 8,
                        shadowColor: const Color(0x3F0041AB),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                        'Login with IITJ ID',
                        style: GoogleFonts.bricolageGrotesque(
                          color: const Color(0xFFCEE2FF),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Guest Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: widget.onGuestLogin,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        side: const BorderSide(
                          color: Color(0xFF1E47F7),
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                      child: Text(
                        'Continue as Guest',
                        style: GoogleFonts.bricolageGrotesque(
                          color: const Color(0xFF1E47F7),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}