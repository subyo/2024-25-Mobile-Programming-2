import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:author/view/login_page.dart';
import 'package:author/view/books_page.dart';
import 'package:author/view_model/login_view_model.dart';
import 'package:author/view_model/books_view_model.dart';

class SplashViewModel with ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;

  redirect(BuildContext context) {
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
}
