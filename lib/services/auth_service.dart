import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// ✅ Sign In with Email & Password
  static Future<User?> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user != null && user.emailVerified) {
        print('✅ Login successful. User is verified.');
        return user;
      } else if (user != null && !user.emailVerified) {
        print('⚠️ Email not verified. Sending verification email again.');
        await user.sendEmailVerification();
        return null; // block access until verified
      }

      return null;
    } on FirebaseAuthException catch (e) {
      print('❌ Email login failed: ${e.code} — ${e.message}');
      return null;
    } catch (e) {
      print('❌ Unknown error in email login: $e');
      return null;
    }
  }

  static Future<User?> signUpWithEmail(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification(); // ✅ Only once here
        print('📩 Verification email sent');
      }

      return user;
    } on FirebaseAuthException catch (e) {
      print('❌ Signup failed: ${e.code} — ${e.message}');
      return null;
    } catch (e) {
      print('❌ Unknown error in signup: $e');
      return null;
    }
  }



  /// ✅ Check if User is Verified (for VerificationScreen)
  static Future<bool> isEmailVerified() async {
    final user = _auth.currentUser;
    await user?.reload(); // refresh status
    return user?.emailVerified ?? false;
  }

  /// ✅ Get current user
  static User? getCurrentUser() {
    return _auth.currentUser;
  }


  static Future<User?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // Web sign-in using popup
        final googleProvider = GoogleAuthProvider();
        final userCredential = await _auth.signInWithPopup(googleProvider);
        return userCredential.user;
      } else {
        // Android/iOS
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) return null;

        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
        return userCredential.user;
      }
    } catch (e) {
      print('Google sign-in error: $e');
      return null;
    }
  }

  static Future<void> signOut() async {
    await _auth.signOut();
    if (!kIsWeb) await GoogleSignIn().signOut();
  }


  static Future<void> verifyPhoneNumber({
    required String phoneNumber,
    int? forceResendingToken, // ⬅️ added for resend
    required void Function(PhoneAuthCredential) onVerificationCompleted,
    required void Function(FirebaseAuthException) onVerificationFailed,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(String) onAutoRetrievalTimeout,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        forceResendingToken: forceResendingToken, // ⬅️ used here
        verificationCompleted: (PhoneAuthCredential credential) {
          print('✅ Auto Verification Completed.');
          onVerificationCompleted(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          print('❌ Verification Failed: ${e.message}');
          onVerificationFailed(e);
        },
        codeSent: (String verificationId, int? resendToken) {
          print('📩 Code Sent. Verification ID: $verificationId');
          onCodeSent(verificationId, resendToken); // ⬅️ we now get resendToken
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print('⏳ Auto retrieval timeout. Verification ID: $verificationId');
          onAutoRetrievalTimeout(verificationId);
        },
      );
    } catch (e) {
      print('❗ Error in verifyPhoneNumber: $e');
    }
  }


  // ✅ Sign in with SMS Code
  static Future<User?> signInWithSMSCode(
      String verificationId, String smsCode) async {
    try {
      final credential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: smsCode);
      final userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);
      print('✅ Phone login success. UID: ${userCredential.user?.uid}');
      return userCredential.user;
    } catch (e) {
      print('❌ Phone sign-in error: $e');
      return null;
    }
  }
}