import 'package:author/main.dart';
import 'package:author/repository/database_repository.dart';
import 'package:flutter/material.dart';
import 'package:author/model/chapter.dart';

class ChapterDetailViewModel with ChangeNotifier {
  final DatabaseRepository _databaseRepository = locator<DatabaseRepository>();

  final Chapter chapter;

  ChapterDetailViewModel(this.chapter);

  void saveContent(String content) async {
    chapter.content = content;
    await _databaseRepository.updateChapter(chapter);
  }
}
