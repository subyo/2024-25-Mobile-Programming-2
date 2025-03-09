class Chapter {
  int? id;
  int bookId;
  String title;
  String content;

  Chapter(this.bookId, this.title) : content = "";

  Map<String, dynamic> toMap() {
    return {
      "id": this.id,
      "bookId": this.bookId,
      "title": this.title,
      "content": this.content,
    };
  }

  Chapter.fromMap(Map<String, dynamic> map)
      : this.id = map["id"],
        this.bookId = map["bookId"],
        this.title = map["title"],
        this.content = map["content"];
}
