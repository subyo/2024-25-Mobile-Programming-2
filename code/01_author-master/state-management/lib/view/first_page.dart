import 'package:state_management/view/redirect_button.dart';
import 'package:state_management/view_model/first_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FirstPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print("Page rebuilt.");
    return Scaffold(
      appBar: AppBar(
        title: Text("First Page"),
      ),
      body: Consumer<FirstViewModel>(
        builder: (context, viewModel, child) {
          print("Container - Consumer built.");
          return Container(
            color: viewModel.color,
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: child,
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FlutterLogo(size: 96),
            _buildTitle(),
            _buildChangeButton(context),
            _buildChangeColorButton(context),
            RedirectButton(),
            _buildCheckboxRow()
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    print("Title built.");
    return Consumer<FirstViewModel>(
      builder: (context, viewModel, child) {
        print("Title - Consumer built.");
        return Text(
          viewModel.text,
          style: TextStyle(fontSize: 28),
        );
      },
    );
  }

  Widget _buildChangeButton(BuildContext context) {
    print("Button built.");
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        child: Text("Change Text"),
        onPressed: () {
          FirstViewModel viewModel = Provider.of<FirstViewModel>(
            context,
            listen: false,
          );
          viewModel.buttonClicked();
        },
      ),
    );
  }

  Widget _buildChangeColorButton(BuildContext context) {
    print("Change color button built.");
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        child: Text("Change Color"),
        onPressed: () {
          FirstViewModel viewModel = Provider.of<FirstViewModel>(
            context,
            listen: false,
          );
          viewModel.changeColor();
        },
      ),
    );
  }

  Widget _buildCheckboxRow() {
    print("Checkbox row built.");
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Checkbox:",
          style: TextStyle(fontSize: 18),
        ),
        Consumer<FirstViewModel>(
          builder: (context, viewModel, child) {
            print("Checkbox - Consumer built.");
            return Checkbox(
              value: viewModel.isCheckboxSelected,
              onChanged: (bool? newValue) {
                viewModel.checkboxValueChanged(newValue);
              },
            );
          },
        ),
      ],
    );
  }
}
