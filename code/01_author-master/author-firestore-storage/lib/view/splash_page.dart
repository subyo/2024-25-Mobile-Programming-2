import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:author/view/login_page.dart';
import 'package:author/view/books_page.dart';

class SplashPage extends StatelessWidget {
  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    _redirect(context);
    return Scaffold(
      body: Center(
        child: Text(
          "Author",
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  _redirect(BuildContext context) {
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      User? user = _auth.currentUser;

      if (user != null) {
        _openBooksPage(context);
      } else {
        _openLoginPage(context);
      }
    });
  }

  void _openLoginPage(BuildContext context) {
    MaterialPageRoute pageRoute = MaterialPageRoute(
      builder: (BuildContext context) {
        return LoginPage();
      },
    );
    Navigator.pushReplacement(context, pageRoute);
  }

  void _openBooksPage(BuildContext context) {
    MaterialPageRoute pageRoute = MaterialPageRoute(
      builder: (BuildContext context) {
        return BooksPage();
      },
    );
    Navigator.pushReplacement(context, pageRoute);
  }
}
