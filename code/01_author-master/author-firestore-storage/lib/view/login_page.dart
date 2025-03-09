import 'package:author/view/books_page.dart';
import 'package:author/view/login_with_phone_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:author/view/register_page.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login Page"),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 32, left: 16, right: 16),
      child: Column(
        children: [
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              labelText: "E - mail",
            ),
          ),
          SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            keyboardType: TextInputType.text,
            obscureText: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              labelText: "Password",
            ),
          ),
          SizedBox(height: 16),
          Container(
            width: double.infinity,
            child: ElevatedButton(
              child: Text("Login"),
              onPressed: () {
                _loginWithEmailAndPassword(context);
              },
            ),
          ),
          SizedBox(height: 16),
          Container(
            width: double.infinity,
            child: ElevatedButton(
              child: Text("Don't have an account? Register"),
              onPressed: () {
                _openRegisterPage(context);
              },
            ),
          ),
          SizedBox(height: 16),
          TextButton(
            child: Text(
              "I forgot my password",
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            onPressed: () {
              _resetPassword(context);
            },
          ),
          Container(
            width: double.infinity,
            child: ElevatedButton(
              child: Text("Login with Google"),
              onPressed: () {
                _loginWithGoogle(context);
              },
            ),
          ),
          Container(
            width: double.infinity,
            child: ElevatedButton(
              child: Text("Login with Apple"),
              onPressed: () {
                _loginWithApple(context);
              },
            ),
          ),
          Container(
            width: double.infinity,
            child: ElevatedButton(
              child: Text("Login with phone number"),
              onPressed: () {
                _loginWithPhoneNumber(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _openBooksPage(BuildContext context) {
    MaterialPageRoute pageRoute = MaterialPageRoute(
      builder: (BuildContext context) {
        return BooksPage();
      },
    );
    Navigator.pushReplacement(context, pageRoute);
  }

  void _loginWithEmailAndPassword(BuildContext context) async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

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

  void _loginWithGoogle(BuildContext context) async {
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

  void _loginWithApple(BuildContext context) async {
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

  void _loginWithPhoneNumber(BuildContext context) async {
    MaterialPageRoute pageRoute = MaterialPageRoute(
      builder: (BuildContext context) {
        return LoginWithPhonePage();
      },
    );
    Navigator.pushReplacement(context, pageRoute);
  }

  void _resetPassword(BuildContext context) async {
    String email = _emailController.text.trim();

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

  void _openRegisterPage(BuildContext context) {
    MaterialPageRoute pageRoute = MaterialPageRoute(
      builder: (BuildContext context) {
        return RegisterPage();
      },
    );
    Navigator.pushReplacement(context, pageRoute);
  }
}
