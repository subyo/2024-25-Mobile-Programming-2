import 'package:flutter/material.dart';

class Chapter with ChangeNotifier {
  dynamic id;
  dynamic bookId;
  String content;
  String userId;

  String _title;

  String get title => _title;

  set title(String value) {
    _title = value;
    notifyListeners();
  }

  Chapter(this.bookId, this._title, this.userId) : content = "";

  Map<String, dynamic> toMap() {
    return {
      "bookId": this.bookId,
      "title": this.title,
      "content": this.content,
      "createdDate": DateTime.now(),
      "userId": this.userId,
    };
  }

  Chapter.fromMap(Map<String, dynamic> map)
      : this.id = map["id"],
        this.bookId = map["bookId"],
        this._title = map["title"],
        this.content = map["content"],
        this.userId = map["userId"] ?? "";
}
