import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:author/view/login_page.dart';
import 'package:author/view/books_page.dart';
import 'package:author/view_model/login_view_model.dart';
import 'package:author/view_model/books_view_model.dart';

class LoginWithPhoneViewModel with ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;

  bool _showVerificationSection = false;

  bool get showVerificationSection => _showVerificationSection;

  set showVerificationSection(bool value) {
    _showVerificationSection = value;
    notifyListeners();
  }

  String _verificationId = "";

  void openLoginPage(BuildContext context) {
    MaterialPageRoute pageRoute = MaterialPageRoute(
      builder: (BuildContext context) {
        return ChangeNotifierProvider(
          create: (BuildContext context) => LoginViewModel(),
          child: LoginPage(),
        );
      },
    );
    Navigator.pushReplacement(context, pageRoute);
  }

  void _openBooksPage(BuildContext context) {
    MaterialPageRoute pageRoute = MaterialPageRoute(
      builder: (BuildContext context) {
        return ChangeNotifierProvider(
          create: (BuildContext context) => BooksViewModel(),
          child: BooksPage(),
        );
      },
    );
    Navigator.pushReplacement(context, pageRoute);
  }

  void _showSnackbar(BuildContext context, String message) {
    SnackBar snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void sendVerificationCode(BuildContext context, String phoneNumber) async {
    if (phoneNumber.isNotEmpty) {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential authCredential) {
          _autoVerification(context, authCredential);
        },
        verificationFailed: _verificationFailed,
        codeSent: _verificationCodeSent,
        codeAutoRetrievalTimeout: _codeTimeOut,
      );
    }
  }

  void _autoVerification(
    BuildContext context,
    PhoneAuthCredential authCredential,
  ) async {
    UserCredential userCredential = await _auth.signInWithCredential(
      authCredential,
    );

    User? user = userCredential.user;
    if (user != null) {
      print("Login with phone number successful.");
      _openBooksPage(context);
    }
  }

  void _verificationFailed(FirebaseAuthException e) {
    if (e.code == 'invalid-phone-number') {
      print("Invalid phone number.");
    } else {
      print("Operation failed.");
    }
  }

  void _verificationCodeSent(String verificationId, int? resendToken) {
    _verificationId = verificationId;
    showVerificationSection = true;
  }

  void _codeTimeOut(String verificationId) {
    print("Verification code timed out.");
  }

  void confirmVerificationCode(
    BuildContext context,
    String verificationCode,
  ) async {
    if (_verificationId.isNotEmpty && verificationCode.isNotEmpty) {
      try {
        PhoneAuthCredential authCredential = PhoneAuthProvider.credential(
          verificationId: _verificationId,
          smsCode: verificationCode,
        );

        UserCredential userCredential = await _auth.signInWithCredential(
          authCredential,
        );

        User? user = userCredential.user;

        if (user != null) {
          _showSnackbar(context, "Login with phone number successful.");
          _openBooksPage(context);
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == "invalid-verification-code") {
          _showSnackbar(context, "Invalid verification code.");
        }
      } catch (e) {
        print(e);
      }
    }
  }
}
