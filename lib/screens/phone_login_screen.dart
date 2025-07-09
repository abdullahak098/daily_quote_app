import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  String? _verificationId;
  int? _resendToken;
  bool _otpSent = false;
  bool _isLoading = false;

  void _sendOTP({bool isResend = false}) async {
    FocusScope.of(context).unfocus();
    final phone = phoneController.text.trim();
    if (phone.isEmpty || phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid phone number')),
      );
      return;
    }

    setState(() => _isLoading = true);

    await AuthService.verifyPhoneNumber(
      phoneNumber: '+92$phone',
      forceResendingToken: isResend ? _resendToken : null,
      onVerificationCompleted: (credential) async {
        final user =
            (await FirebaseAuth.instance.signInWithCredential(credential))
                .user;
        if (user != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      },
      onVerificationFailed: (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification failed: ${e.message}')),
        );
        setState(() => _isLoading = false);
      },
      onCodeSent: (verificationId, resendToken) {
        setState(() {
          _otpSent = true;
          _verificationId = verificationId;
          _resendToken = resendToken; // ✅ Store resend token
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP Sent Successfully')),
        );
      },
      onAutoRetrievalTimeout: (verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  void _verifyOTP() async {
    FocusScope.of(context).unfocus();
    final smsCode = otpController.text.trim();
    if (smsCode.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid 6-digit OTP')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final user =
    await AuthService.signInWithSMSCode(_verificationId!, smsCode);
    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid OTP')),
      );
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Phone Login'),
        backgroundColor: Colors.deepPurple,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding:
        const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Login with Phone',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'You will receive a 6-digit code to verify your number.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 36),

            /// Phone Number Input
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.phone),
                prefixText: '+92 ',
                labelText: 'Phone Number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 24),

            if (_otpSent) ...[
              /// OTP Input
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock_outline),
                  labelText: 'Enter OTP',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 24),

              /// Verify OTP Button (Centered and Prominent)
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.verified, size: 28),
                  label: const Text(
                    'Verify OTP & Login',
                    style: TextStyle(
                      fontSize: 20, // Prominent text
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  onPressed: _verifyOTP,
                ),
              ),
              /// Resend OTP Button (Centered)
              Center(
                child: TextButton.icon(
                  icon: const Icon(Icons.refresh, color: Colors.deepPurple),
                  label: const Text(
                    'Resend OTP',
                    style: TextStyle(
                      color: Colors.deepPurple,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () => _sendOTP(isResend: true),
                ),
              ),

            ] else ...[
              /// Send OTP Button (Centered with Prominent Text)
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.send_to_mobile, size: 28),
                  label: const Text(
                    'Send OTP',
                    style: TextStyle(
                      fontSize: 20, // Make text prominent
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  onPressed: _sendOTP,
                ),
              ),

            ],
          ],
        ),
      ),
    );
  }
}
