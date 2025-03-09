import 'package:author/repository/auth_repository.dart';
import 'package:author/repository/database_repository.dart';
import 'package:author/repository/storage_repository.dart';
import 'package:author/service/auth_service_firebase.dart';
import 'package:author/service/database_service_firestore.dart';
import 'package:author/service/database_service_sqflite.dart';
import 'package:author/service/storage_service_firebase.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:author/view/splash_page.dart';
import 'package:author/view_model/splash_view_model.dart';

GetIt locator = GetIt.instance;

setupLocator() {
  locator.registerLazySingleton(() => DatabaseRepository());
  locator.registerLazySingleton(() => FirestoreDatabaseService());
  locator.registerLazySingleton(() => SqfliteDatabaseService());

  locator.registerLazySingleton(() => AuthRepository());
  locator.registerLazySingleton(() => FirebaseAuthService());

  locator.registerLazySingleton(() => StorageRepository());
  locator.registerLazySingleton(() => FirebaseStorageService());
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  setupLocator();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChangeNotifierProvider(
        create: (BuildContext context) => SplashViewModel(),
        child: SplashPage(),
      ),
    );
  }
}
