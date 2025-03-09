import 'package:author/database/remote_database.dart';
import 'package:author/view/chapter_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:author/model/chapter.dart';
import 'package:author/model/book.dart';
import 'package:author/database/local_database.dart';

class ChaptersPage extends StatefulWidget {
  final Book book;

  ChaptersPage(this.book);

  @override
  _ChaptersPageState createState() => _ChaptersPageState();
}

class _ChaptersPageState extends State<ChaptersPage> {
  LocalDatabase _localDatabase = LocalDatabase();
  RemoteDatabase _remoteDatabase = RemoteDatabase();

  List<Chapter> _chapters = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.name),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          _addChapter(context);
        },
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return FutureBuilder<void>(
      future: _getAllChapters(),
      builder: _buildListView,
    );
  }

  Widget _buildListView(BuildContext context, AsyncSnapshot<void> snapshot) {
    return ListView.builder(
      itemCount: _chapters.length,
      itemBuilder: _buildListTile,
    );
  }

  Widget _buildListTile(BuildContext context, int index) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(_chapters[index].id.toString()),
      ),
      title: Text(_chapters[index].title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              _updateChapter(context, index);
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _deleteChapter(index);
            },
          ),
        ],
      ),
      onTap: () {
        _openChapterDetailPage(context, index);
      },
    );
  }

  void _addChapter(BuildContext context) async {
    String chapterTitle = await _openDialog(context, "Enter Chapter Title") ?? "";
    dynamic bookId = widget.book.id;
    if (chapterTitle.isNotEmpty && bookId != null) {
      Chapter newChapter = Chapter(bookId, chapterTitle, widget.book.userId);
      dynamic chapterId = await _remoteDatabase.createChapter(newChapter);
      debugPrint("Chapter Id: " + chapterId.toString());
      setState(() {});
    }
  }

  Future<void> _getAllChapters() async {
    dynamic userId = widget.book.userId;
    dynamic bookId = widget.book.id;
    if (userId != null && bookId != null) {
      _chapters = await _remoteDatabase.readAllChapters(
        userId,
        bookId,
      );
    }
  }

  void _updateChapter(BuildContext context, int index) async {
    String newChapterTitle = await _openDialog(context, "Update Chapter") ?? "";
    if (newChapterTitle.isNotEmpty) {
      Chapter chapter = _chapters[index];
      chapter.title = newChapterTitle;
      int updatedRowCount = await _remoteDatabase.updateChapter(chapter);
      if (updatedRowCount > 0) {
        setState(() {});
      }
    }
  }

  void _deleteChapter(int index) async {
    Chapter chapter = _chapters[index];
    int deletedRowCount = await _remoteDatabase.deleteChapter(chapter);
    if (deletedRowCount > 0) {
      setState(() {});
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

  void _openChapterDetailPage(BuildContext context, int index) {
    MaterialPageRoute pageRoute = MaterialPageRoute(
      builder: (BuildContext context) {
        return ChapterDetailPage(_chapters[index]);
      },
    );
    Navigator.push(context, pageRoute);
  }
}
