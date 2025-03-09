import 'package:flutter/material.dart';

class Book with ChangeNotifier {
  dynamic id;
  DateTime createdDate;
  String userId;

  String _name;

  String get name => _name;

  set name(String value) {
    _name = value;
    notifyListeners();
  }

  int _category;

  int get category => _category;

  set category(int value) {
    _category = value;
    notifyListeners();
  }

  String? _image;

  String? get image => _image;

  set image(String? value) {
    _image = value;
    notifyListeners();
  }

  bool _isChosen = false;

  bool get isChosen => _isChosen;

  set isChosen(bool value) {
    _isChosen = value;
    notifyListeners();
  }

  Book(this._name, this.createdDate, this._category, this.userId);

  Map<String, dynamic> toMap() {
    return {
      "name": this.name,
      "createdDate": createdDate,
      "category": this.category,
      "userId": this.userId,
      "image": this.image,
    };
  }

  Book.fromMap(Map<String, dynamic> map)
      : this.id = map["id"],
        this._name = map["name"],
        this.createdDate = map["createdDate"],
        this._category = map["category"] ?? 0,
        this.userId = map["userId"] ?? "",
        this._image = map["image"];
}
