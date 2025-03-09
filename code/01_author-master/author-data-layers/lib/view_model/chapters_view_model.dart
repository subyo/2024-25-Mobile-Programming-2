import 'package:author/main.dart';
import 'package:author/repository/database_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:author/model/chapter.dart';
import 'package:author/model/book.dart';
import 'package:author/view/chapter_detail_page.dart';
import 'package:author/view_model/chapter_detail_view_model.dart';

class ChaptersViewModel with ChangeNotifier {
  final DatabaseRepository _databaseRepository = locator<DatabaseRepository>();

  List<Chapter> chapters = [];

  final Book book;

  ChaptersViewModel(this.book) {
    _getAllChapters();
  }

  void addChapter(BuildContext context) async {
    String chapterTitle =
        await _openDialog(context, "Enter Chapter Title") ?? "";
    dynamic bookId = book.id;
    if (chapterTitle.isNotEmpty && bookId != null) {
      Chapter newChapter = Chapter(bookId, chapterTitle, book.userId);
      dynamic chapterId = await _databaseRepository.createChapter(newChapter);
      debugPrint("Chapter Id: " + chapterId.toString());
      notifyListeners();
    }
  }

  Future<void> _getAllChapters() async {
    dynamic userId = book.userId;
    dynamic bookId = book.id;
    if (userId != null && bookId != null) {
      chapters = await _databaseRepository.readAllChapters(userId, bookId);
    }
    notifyListeners();
  }

  void updateChapter(BuildContext context, int index) async {
    String newChapterTitle = await _openDialog(context, "Update Chapter") ?? "";
    if (newChapterTitle.isNotEmpty) {
      Chapter chapter = chapters[index];
      chapter.title = newChapterTitle;
      int updatedRowCount = await _databaseRepository.updateChapter(chapter);
      if (updatedRowCount > 0) {
        //notifyListeners();
      }
    }
  }

  void deleteChapter(int index) async {
    Chapter chapter = chapters[index];
    int deletedRowCount = await _databaseRepository.deleteChapter(chapter);
    if (deletedRowCount > 0) {
      notifyListeners();
    }
  }

  Future<String?> _openDialog(BuildContext context, String title) {
    return showDialog<String>(
      context: context,
      builder: (context) {
        String result = "";
        return AlertDialog(
          title: Text(title),
          content: TextField(
            keyboardType: TextInputType.text,
            onChanged: (String inputText) {
              result = inputText;
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.pop(context, "");
              },
            ),
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.pop(context, result.trim());
              },
            ),
          ],
        );
      },
    );
  }

  void openChapterDetailPage(BuildContext context, int index) {
    MaterialPageRoute pageRoute = MaterialPageRoute(
      builder: (BuildContext context) {
        return ChangeNotifierProvider(
          create: (BuildContext context) => ChapterDetailViewModel(
            chapters[index],
          ),
          child: ChapterDetailPage(),
        );
      },
    );
    Navigator.push(context, pageRoute);
  }
}
