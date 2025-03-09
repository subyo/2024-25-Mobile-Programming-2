class Book {
  int? id;
  String name;
  DateTime createdDate;
  int category;

  Book(this.name, this.createdDate, this.category);

  Map<String, dynamic> toMap() {
    return {
      "id": this.id,
      "name": this.name,
      "createdDate": this.createdDate.millisecondsSinceEpoch,
      "category": this.category,
    };
  }

  Book.fromMap(Map<String, dynamic> map)
      : this.id = map["id"],
        this.name = map["name"],
        this.createdDate =
            DateTime.fromMillisecondsSinceEpoch(map["createdDate"]),
        this.category = map["category"] ?? 0;
}
