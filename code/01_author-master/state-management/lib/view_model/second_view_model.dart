import 'package:state_management/model/order.dart';
import 'package:flutter/material.dart';

class SecondViewModel with ChangeNotifier {
  List<Order> orders = [];

  SecondViewModel() {
    for (int i = 1; i <= 5; i++) {
      Order order = Order("Order $i", "Waiting for Approval...");
      orders.add(order);
    }
  }

  void approveOrder(Order order) {
    int index = orders.indexWhere((s) => s.title == order.title);
    orders[index].status = "Approved";
    notifyListeners();
  }
}
