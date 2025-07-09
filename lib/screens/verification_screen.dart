import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  bool _isVerifying = false;

  Future<void> _checkEmailVerified() async {
    setState(() => _isVerifying = true);

    final user = FirebaseAuth.instance.currentUser;
    await user?.reload();
    final updatedUser = FirebaseAuth.instance.currentUser;

    if (updatedUser != null && updatedUser.emailVerified) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Email not verified yet. Please check your inbox."),
        ),
      );
    }

    setState(() => _isVerifying = false);
  }

  Future<void> _resendVerificationEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('📩 Verification email re-sent.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: const Text("Email Verification"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.mark_email_unread_rounded,
                  size: 110, color: Colors.deepPurple),
              const SizedBox(height: 30),

              const Text(
                '📬 Verify Your Email',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 10),

              const Text(
                'We’ve sent a verification link to your email address.\nPlease check your inbox.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 17, color: Colors.black87),
              ),
              const SizedBox(height: 40),

              _isVerifying
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                icon: const Icon(
                  Icons.verified,
                  size: 28,
                  color: Colors.white,
                ),
                label: const Text(
                  "I'VE VERIFIED MY EMAIL",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.0,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 5,
                ),
                onPressed: _checkEmailVerified,
              ),

              const SizedBox(height: 20),

              TextButton.icon(
                onPressed: _resendVerificationEmail,
                icon: const Icon(Icons.refresh, color: Colors.deepPurple),
                label: const Text(
                  "Resend Verification Email",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
