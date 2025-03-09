import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:author/view_model/login_view_model.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

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
                LoginViewModel viewModel = Provider.of<LoginViewModel>(
                  context,
                  listen: false,
                );
                viewModel.loginWithEmailAndPassword(
                  context,
                  _emailController.text.trim(),
                  _passwordController.text.trim(),
                );
              },
            ),
          ),
          SizedBox(height: 16),
          Container(
            width: double.infinity,
            child: ElevatedButton(
              child: Text("Don't have an account? Register"),
              onPressed: () {
                LoginViewModel viewModel = Provider.of<LoginViewModel>(
                  context,
                  listen: false,
                );
                viewModel.openRegisterPage(context);
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
              LoginViewModel viewModel = Provider.of<LoginViewModel>(
                context,
                listen: false,
              );
              viewModel.resetPassword(context, _emailController.text.trim());
            },
          ),
          Container(
            width: double.infinity,
            child: ElevatedButton(
              child: Text("Login with Google"),
              onPressed: () {
                LoginViewModel viewModel = Provider.of<LoginViewModel>(
                  context,
                  listen: false,
                );
                viewModel.loginWithGoogle(context);
              },
            ),
          ),
          Container(
            width: double.infinity,
            child: ElevatedButton(
              child: Text("Login with Apple"),
              onPressed: () {
                LoginViewModel viewModel = Provider.of<LoginViewModel>(
                  context,
                  listen: false,
                );
                viewModel.loginWithApple(context);
              },
            ),
          ),
          Container(
            width: double.infinity,
            child: ElevatedButton(
              child: Text("Login with phone number"),
              onPressed: () {
                LoginViewModel viewModel = Provider.of<LoginViewModel>(
                  context,
                  listen: false,
                );
                viewModel.loginWithPhoneNumber(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
