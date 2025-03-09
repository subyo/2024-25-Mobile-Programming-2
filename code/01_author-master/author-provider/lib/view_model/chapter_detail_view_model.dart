import 'package:flutter/material.dart';
import 'package:author/model/chapter.dart';
import 'package:author/database/remote_database.dart';
import 'package:author/database/local_database.dart';

class ChapterDetailViewModel with ChangeNotifier {
  LocalDatabase _localDatabase = LocalDatabase();
  RemoteDatabase _remoteDatabase = RemoteDatabase();

  final Chapter chapter;

  ChapterDetailViewModel(this.chapter);

  void saveContent(String content) async {
    chapter.content = content;
    await _remoteDatabase.updateChapter(chapter);
  }
}
