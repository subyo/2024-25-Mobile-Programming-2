import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:author/service/base/storage_service.dart';

class FirebaseStorageService implements StorageService {
  FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  Future<String> uploadFile(String filePath, File file) async {
    TaskSnapshot uploadTask = await _storage.ref(filePath).putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }
}
