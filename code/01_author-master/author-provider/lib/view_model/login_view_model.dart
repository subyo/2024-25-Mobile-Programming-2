import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:author/view/register_page.dart';
import 'package:author/view/books_page.dart';
import 'package:author/view/login_with_phone_page.dart';
import 'package:author/view_model/register_view_model.dart';
import 'package:author/view_model/books_view_model.dart';
import 'package:author/view_model/login_with_phone_view_model.dart';

class LoginViewModel with ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;

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
        return BooksPage();
      },
    );
    Navigator.pushReplacement(context, pageRoute);
  }

  void loginWithEmailAndPassword(
    BuildContext context,
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        _showSnackbar(context, "Login successful.");
        print(_auth.currentUser?.emailVerified ?? 'No account');
        _openBooksPage(context);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        _showSnackbar(context, "User not found.");
      } else if (e.code == "wrong-password") {
        _showSnackbar(context, "Password is wrong.");
      }
    } catch (e) {
      print(e);
    }
  }

  void loginWithGoogle(BuildContext context) async {
    GoogleSignIn googleSignIn = GoogleSignIn(scopes: ["email"]);

    GoogleSignInAccount? googleAccount = await googleSignIn.signIn();

    if (googleAccount != null) {
      GoogleSignInAuthentication googleAuth =
          await googleAccount.authentication;

      AuthCredential authCredential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential userCredential = await _auth.signInWithCredential(
        authCredential,
      );

      User? user = userCredential.user;
      if (user != null) {
        _showSnackbar(context, "Login with Google successful.");
        _openBooksPage(context);
      }
    }
  }

  void loginWithApple(BuildContext context) async {
    AuthorizationCredentialAppleID appleId =
        await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
      ],
    );

    OAuthProvider oAuthProvider = OAuthProvider("apple.com");

    AuthCredential authCredential = oAuthProvider.credential(
      accessToken: appleId.authorizationCode,
      idToken: appleId.identityToken,
    );
    UserCredential userCredential = await _auth.signInWithCredential(
      authCredential,
    );

    User? user = userCredential.user;
    if (user != null) {
      _showSnackbar(context, "Login with Apple successful.");
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
      await _auth.sendPasswordResetEmail(email: email);
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
