import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:state_management/view/second_page.dart';
import 'package:state_management/view_model/second_view_model.dart';

class FirstViewModel with ChangeNotifier {
  Color _color = Colors.white;

  Color get color => _color;

  set color(Color value) {
    _color = value;
    notifyListeners();
  }

  String _text = "Hello";

  String get text => _text;

  set text(String value) {
    _text = value;
    notifyListeners();
  }

  bool _isCheckboxSelected = false;

  bool get isCheckboxSelected => _isCheckboxSelected;

  set isCheckboxSelected(bool value) {
    _isCheckboxSelected = value;
    notifyListeners();
  }

  void buttonClicked() {
    text = "Button Clicked";
  }

  void checkboxValueChanged(bool? newValue) {
    if (newValue != null) {
      isCheckboxSelected = newValue;
    }
  }

  void changeColor() {
    color = Colors.grey;
  }

  void openSecondPage(BuildContext context) {
    MaterialPageRoute pageRoute = MaterialPageRoute(
      builder: (BuildContext context) {
        return ChangeNotifierProvider(
          create: (BuildContext context) => SecondViewModel(),
          child: SecondPage(),
        );
      },
    );
    Navigator.pushReplacement(context, pageRoute);
  }
}
