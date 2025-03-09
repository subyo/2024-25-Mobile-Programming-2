import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:author/view_model/splash_view_model.dart';

class SplashPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SplashViewModel viewModel = Provider.of<SplashViewModel>(
      context,
      listen: false,
    );
    viewModel.redirect(context);
    return Scaffold(
      body: Center(
        child: Text(
          "Author",
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
