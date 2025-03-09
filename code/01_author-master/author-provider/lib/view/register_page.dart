import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:author/view_model/register_view_model.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController _fullNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

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
                RegisterViewModel viewModel = Provider.of<RegisterViewModel>(
                  context,
                  listen: false,
                );
                viewModel.registerWithEmailAndPassword(
                  context,
                  _fullNameController.text.trim(),
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
              child: Text("Already have an account? Login"),
              onPressed: () {
                RegisterViewModel viewModel = Provider.of<RegisterViewModel>(
                  context,
                  listen: false,
                );
                viewModel.openLoginPage(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
