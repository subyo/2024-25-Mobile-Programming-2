import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:author/main.dart';
import 'package:author/repository/auth_repository.dart';
import 'package:author/view/register_page.dart';
import 'package:author/view/books_page.dart';
import 'package:author/view/login_with_phone_page.dart';
import 'package:author/view_model/register_view_model.dart';
import 'package:author/view_model/books_view_model.dart';
import 'package:author/view_model/login_with_phone_view_model.dart';

class LoginViewModel with ChangeNotifier {
  final AuthRepository _authRepository = locator<AuthRepository>();

  void openRegisterPage(BuildContext context) {
    MaterialPageRoute pageRoute = MaterialPageRoute(
      builder: (BuildContext context) {
        return ChangeNotifierProvider(
          create: (BuildContext context) => RegisterViewModel(),
          child: RegisterPage(),
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

  void loginWithEmailAndPassword(
    BuildContext context,
    String email,
    String password,
  ) async {
    dynamic userId =
        await _authRepository.loginWithEmailAndPassword(email, password);
    if (userId != null) {
      _openBooksPage(context);
    }
  }

  void loginWithGoogle(BuildContext context) async {
    dynamic userId = await _authRepository.loginWithGoogle();
    if (userId != null) {
      _openBooksPage(context);
    }
  }

  void loginWithApple(BuildContext context) async {
    dynamic userId = await _authRepository.loginWithApple();
    if (userId != null) {
      _openBooksPage(context);
    }
  }

  void loginWithPhoneNumber(BuildContext context) async {
    MaterialPageRoute pageRoute = MaterialPageRoute(
      builder: (BuildContext context) {
        return ChangeNotifierProvider(
          create: (BuildContext context) => LoginWithPhoneViewModel(),
          child: LoginWithPhonePage(),
        );
      },
    );
    Navigator.pushReplacement(context, pageRoute);
  }

  void resetPassword(BuildContext context, String email) async {
    if (email.isNotEmpty) {
      await _authRepository.resetPassword(email);
      _showSnackbar(context, "Password reset link has been sent.");
    } else {
      _showSnackbar(context, "Please enter your e-mail address.");
    }
  }

  void _showSnackbar(BuildContext context, String message) {
    SnackBar snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
