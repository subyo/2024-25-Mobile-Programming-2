import 'package:author/view/books_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:author/view/login_page.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController _fullNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Register Page"),
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
            controller: _fullNameController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              labelText: "Full Name",
            ),
          ),
          SizedBox(height: 16),
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
              child: Text("Register"),
              onPressed: () {
                _registerWithEmailAndPassword(context);
              },
            ),
          ),
          SizedBox(height: 16),
          Container(
            width: double.infinity,
            child: ElevatedButton(
              child: Text("Already have an account? Login"),
              onPressed: () {
                _openLoginPage(context);
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

  void _registerWithEmailAndPassword(BuildContext context) async {
    String fullName = _fullNameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
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
        _showSnackbar(context, "An account has already been created with this e-mail.");
      }
    } catch (e) {
      print(e);
    }
  }

  void _showSnackbar(BuildContext context, String message) {
    SnackBar snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _openLoginPage(BuildContext context) {
    MaterialPageRoute pageRoute = MaterialPageRoute(
      builder: (BuildContext context) {
        return LoginPage();
      },
    );
    Navigator.pushReplacement(context, pageRoute);
  }
}
