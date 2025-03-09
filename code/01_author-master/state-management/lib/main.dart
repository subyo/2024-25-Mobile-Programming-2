import 'package:provider/provider.dart';
import 'package:state_management/view/first_page.dart';
import 'package:flutter/material.dart';
import 'package:state_management/view_model/first_view_model.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChangeNotifierProvider(
        create: (BuildContext context) => FirstViewModel(),
        child: FirstPage(),
      ),
    );
  }
}

/*
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (BuildContext context) => FirstViewModel(),
          ),
          ChangeNotifierProvider(
            create: (BuildContext context) => OtherChangeNotifier(),
          ),
        ],
        child: FirstPage(),
      ),
    );
  }
}
*/
