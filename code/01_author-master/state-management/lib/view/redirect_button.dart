import 'package:state_management/view_model/first_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RedirectButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: Text("Open Second Page"),
      onPressed: () {
        FirstViewModel viewModel = Provider.of<FirstViewModel>(
          context,
          listen: false,
        );
        viewModel.openSecondPage(context);
      },
    );
  }
}
