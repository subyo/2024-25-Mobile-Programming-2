import 'package:state_management/model/order.dart';
import 'package:state_management/view_model/second_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SecondPage extends StatelessWidget {
  const SecondPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Second Page"),
      ),
      body: _buildListView(),
    );
  }

  Widget _buildListView() {
    return Consumer<SecondViewModel>(
      builder: (context, viewModel, child) {
        print("ListView - Consumer built.");
        return ListView.builder(
          itemCount: viewModel.orders.length,
          itemBuilder: (BuildContext context, int index) {
            return ChangeNotifierProvider.value(
              value: viewModel.orders[index],
              child: _buildListTile(),
            );
          },
        );
      },
    );
  }

  Widget _buildListTile() {
    print("ListTile built.");
    return Consumer<Order>(
      builder: (context, order, child) {
        print("ListTile ${order.title} - Consumer built.");
        return ListTile(
          title: Text(order.title),
          subtitle: Text(order.status),
          onTap: () {
            order.approveOrder();
          },
        );
      },
    );
  }
}
