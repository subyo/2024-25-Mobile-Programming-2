import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:author/main.dart';
import 'package:author/repository/auth_repository.dart';
import 'package:author/view/login_page.dart';
import 'package:author/view/books_page.dart';
import 'package:author/view_model/login_view_model.dart';
import 'package:author/view_model/books_view_model.dart';

class LoginWithPhoneViewModel with ChangeNotifier {
  final AuthRepository _authRepository = locator<AuthRepository>();

  bool _showVerificationSection = false;

  bool get showVerificationSection => _showVerificationSection;

  set showVerificationSection(bool value) {
    _showVerificationSection = value;
    notifyListeners();
  }

  dynamic _verificationId = "";

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

  void sendVerificationCode(
    BuildContext context,
    String phoneNumber,
  ) async {
    if (phoneNumber.isNotEmpty) {
      await _authRepository.sendPhoneVerificationCode(
        phoneNumber,
        autoVerification: (userId) {
          _autoVerification(context, userId);
        },
        verificationFailed: _verificationFailed,
        verificationCodeSent: _verificationCodeSent,
        codeTimeOut: _codeTimeOut,
      );
    }
  }

  void _autoVerification(BuildContext context, userId) async {
    if (userId != null) {
      print("Login with phone number successful.");
      _openBooksPage(context);
    }
  }

  void _verificationFailed(String error) {
    if (error == 'invalid-phone-number') {
      print("Invalid phone number.");
    } else {
      print("Operation failed.");
    }
  }

  void _verificationCodeSent(verificationId) {
    _verificationId = verificationId;
    showVerificationSection = true;
  }

  void _codeTimeOut() {
    print("Verification code timed out.");
  }

  void confirmVerificationCode(
    BuildContext context,
    String verificationCode,
  ) async {
    if (_verificationId.isNotEmpty && verificationCode.isNotEmpty) {
      dynamic userId = await _authRepository.confirmPhoneVerificationCode(
          _verificationId, verificationCode);
      if (userId != null) {
        _openBooksPage(context);
      }
    }
  }
}
