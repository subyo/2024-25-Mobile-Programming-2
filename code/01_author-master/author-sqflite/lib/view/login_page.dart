import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:author/view/books_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _passwordController = TextEditingController();

  String _currentPassword = "";

  @override
  void initState() {
    super.initState();
    _getPassword();
  }

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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _currentPassword.isNotEmpty
                ? "Login with\nCurrent Password"
                : "Welcome!\nSet a Password",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 28),
          ),
          SizedBox(height: 20),
          TextField(
            controller: _passwordController,
            decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                labelText: "Enter password"),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            child: Text(_currentPassword.isNotEmpty ? "Login" : "Save"),
            onPressed: () {
              if (_currentPassword.isNotEmpty) {
                _login(context);
              } else {
                _savePassword(context);
              }
            },
          ),
        ],
      ),
    );
  }

  void _savePassword(BuildContext context) async {
    String enteredPassword = _passwordController.text;
    if (enteredPassword.isNotEmpty) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("password", enteredPassword);
      _openBooksPage(context);
    }
  }

  void _getPassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String readValue = await prefs.getString("password") ?? "";
    setState(() {
      _currentPassword = readValue;
    });
  }

  void _login(BuildContext context) {
    if (_passwordController.text == _currentPassword) {
      _openBooksPage(context);
    }
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
