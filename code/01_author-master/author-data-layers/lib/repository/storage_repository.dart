import 'dart:io';

import 'package:author/base/storage_base.dart';
import 'package:author/main.dart';
import 'package:author/service/base/storage_service.dart';
import 'package:author/service/storage_service_firebase.dart';

class StorageRepository implements StorageBase {
  final StorageService _service = locator<FirebaseStorageService>();

  @override
  Future<String> uploadFile(String filePath, File file) async {
    return await _service.uploadFile(filePath, file);
  }
}
