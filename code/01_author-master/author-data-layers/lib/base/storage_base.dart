import 'dart:io';

abstract class StorageBase {
  Future<String> uploadFile(String filePath, File file);
}
