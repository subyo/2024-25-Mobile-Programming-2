import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  dynamic id;
  String name;
  DateTime createdDate;
  int category;
  String userId;
  String? image;

  Book(this.name, this.createdDate, this.category, this.userId);

  Map<String, dynamic> toMap() {
    return {
      "name": this.name,
      "createdDate": FieldValue.serverTimestamp(),
      "category": this.category,
      "userId": this.userId,
      "image": this.image,
    };
  }

  Book.fromMap(Map<String, dynamic> map)
      : this.id = map["id"],
        this.name = map["name"],
        this.createdDate = (map["createdDate"] as Timestamp).toDate(),
        this.category = map["category"] ?? 0,
        this.userId = map["userId"],
        this.image = map["image"];
}
