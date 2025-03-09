import 'package:cloud_firestore/cloud_firestore.dart';

class Chapter {
  dynamic id;
  dynamic bookId;
  String title;
  String content;
  String userId;

  Chapter(this.bookId, this.title, this.userId) : content = "";

  Map<String, dynamic> toMap() {
    return {
      "bookId": this.bookId,
      "title": this.title,
      "content": this.content,
      "createdDate": FieldValue.serverTimestamp(),
      "userId": this.userId,
    };
  }

  Chapter.fromMap(Map<String, dynamic> map)
      : this.id = map["id"],
        this.bookId = map["bookId"],
        this.title = map["title"],
        this.content = map["content"],
        this.userId = map["userId"];
}
