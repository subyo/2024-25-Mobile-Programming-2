import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:author/view_model/login_with_phone_view_model.dart';

class LoginWithPhonePage extends StatefulWidget {
  @override
  State<LoginWithPhonePage> createState() => _LoginWithPhonePageState();
}

class _LoginWithPhonePageState extends State<LoginWithPhonePage> {
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _verificationCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login with Phone Number"),
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
            controller: _phoneNumberController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              labelText: "Phone number",
            ),
          ),
          SizedBox(height: 16),
          Container(
            width: double.infinity,
            child: ElevatedButton(
              child: Text("Send verification code"),
              onPressed: () {
                LoginWithPhoneViewModel viewModel =
                    Provider.of<LoginWithPhoneViewModel>(
                  context,
                  listen: false,
                );
                viewModel.sendVerificationCode(
                  context,
                  _phoneNumberController.text.trim(),
                );
              },
            ),
          ),
          SizedBox(height: 48),
          Consumer<LoginWithPhoneViewModel>(
            builder: (context, viewModel, child) {
              return Visibility(
                visible: viewModel.showVerificationSection,
                child: child!,
              );
            },
            child: Column(
              children: [
                TextField(
                  controller: _verificationCodeController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelText: "Verification code",
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    child: Text("Confirm verification code"),
                    onPressed: () {
                      LoginWithPhoneViewModel viewModel =
                          Provider.of<LoginWithPhoneViewModel>(
                        context,
                        listen: false,
                      );
                      viewModel.confirmVerificationCode(
                        context,
                        _verificationCodeController.text.trim(),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 48),
          Container(
            width: double.infinity,
            child: ElevatedButton(
              child: Text("Other login methods"),
              onPressed: () {
                LoginWithPhoneViewModel viewModel =
                    Provider.of<LoginWithPhoneViewModel>(
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
