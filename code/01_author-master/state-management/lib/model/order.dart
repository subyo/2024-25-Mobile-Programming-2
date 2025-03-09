import 'package:flutter/material.dart';

class Order with ChangeNotifier {
  String title;
  String status;

  Order(this.title, this.status);

  void approveOrder() {
    status = "Approved";
    notifyListeners();
  }
}
