import 'package:author/view/books_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:author/view/login_page.dart';

class LoginWithPhonePage extends StatefulWidget {
  @override
  State<LoginWithPhonePage> createState() => _LoginWithPhonePageState();
}

class _LoginWithPhonePageState extends State<LoginWithPhonePage> {
  TextEditingController _phoneNumberController = TextEditingController();

  TextEditingController _verificationCodeController = TextEditingController();

  FirebaseAuth _auth = FirebaseAuth.instance;

  bool _showVerificationSection = false;

  String _verificationId = "";

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
              onPressed: _sendVerificationCode,
            ),
          ),
          SizedBox(height: 48),
          Visibility(
            visible: _showVerificationSection,
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
                      _confirmVerificationCode(context);
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
                _openLoginPage(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _openLoginPage(BuildContext context) {
    MaterialPageRoute pageRoute = MaterialPageRoute(
      builder: (BuildContext context) {
        return LoginPage();
      },
    );
    Navigator.pushReplacement(context, pageRoute);
  }

  void _showSnackbar(BuildContext context, String message) {
    SnackBar snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _sendVerificationCode() async {
    String phoneNumber = _phoneNumberController.text.trim();

    if (phoneNumber.isNotEmpty) {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: _autoVerification,
        verificationFailed: _verificationFailed,
        codeSent: _verificationCodeSent,
        codeAutoRetrievalTimeout: _codeTimeOut,
      );
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

  void _autoVerification(PhoneAuthCredential authCredential) async {
    UserCredential userCredential = await _auth.signInWithCredential(
      authCredential,
    );

    User? user = userCredential.user;
    if (user != null) {
      print("Login with phone number successful.");
      _openBooksPage(context);
    }
  }

  void _verificationFailed(FirebaseAuthException e) {
    if (e.code == 'invalid-phone-number') {
      print("Invalid phone number.");
    } else {
      print("Operation failed.");
    }
  }

  void _verificationCodeSent(String verificationId, int? resendToken) {
    _verificationId = verificationId;

    setState(() {
      _showVerificationSection = true;
    });
  }

  void _codeTimeOut(String verificationId) {
    print("Verification code timed out.");
  }

  void _confirmVerificationCode(BuildContext context) async {
    String verificationCode = _verificationCodeController.text.trim();

    if (_verificationId.isNotEmpty && verificationCode.isNotEmpty) {
      try {
        PhoneAuthCredential authCredential = PhoneAuthProvider.credential(
          verificationId: _verificationId,
          smsCode: verificationCode,
        );

        UserCredential userCredential = await _auth.signInWithCredential(
          authCredential,
        );

        User? user = userCredential.user;

        if (user != null) {
          _showSnackbar(context, "Login with phone number successful.");
          _openBooksPage(context);
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == "invalid-verification-code") {
          _showSnackbar(context, "Invalid verification code.");
        }
      } catch (e) {
        print(e);
      }
    }
  }
}
