import 'package:author/database/remote_database.dart';
import 'package:flutter/material.dart';
import 'package:author/model/chapter.dart';
import 'package:author/database/local_database.dart';

class ChapterDetailPage extends StatelessWidget {
  final Chapter chapter;

  ChapterDetailPage(this.chapter);

  LocalDatabase _localDatabase = LocalDatabase();
  RemoteDatabase _remoteDatabase = RemoteDatabase();

  TextEditingController _contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(chapter.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveContent,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    _contentController.text = chapter.content;
    return Container(
      padding: EdgeInsets.all(16.0),
      child: TextField(
        controller: _contentController,
        maxLines: 1000,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
        ),
      ),
    );
  }

  void _saveContent() async {
    chapter.content = _contentController.text;
    await _remoteDatabase.updateChapter(chapter);
  }
}
