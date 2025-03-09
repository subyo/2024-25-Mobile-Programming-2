import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:author/view/login_page.dart';
import 'package:author/view/books_page.dart';
import 'package:author/view_model/login_view_model.dart';
import 'package:author/view_model/books_view_model.dart';

class RegisterViewModel with ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;

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

  void registerWithEmailAndPassword(
    BuildContext context,
    String fullName,
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      await user?.updateDisplayName(fullName);
      await user?.sendEmailVerification();

      _openBooksPage(context);
    } on FirebaseAuthException catch (e) {
      if (e.code == "weak-password") {
        _showSnackbar(context, "Password is too weak.");
      } else if (e.code == "email-already-in-use") {
        _showSnackbar(
          context,
          "An account has already been created with this e-mail.",
        );
      }
    } catch (e) {
      print(e);
    }
  }

  void _showSnackbar(BuildContext context, String message) {
    SnackBar snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
