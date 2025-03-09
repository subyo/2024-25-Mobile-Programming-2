import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:author/model/chapter.dart';
import 'package:author/model/book.dart';

class RemoteDatabase {
  RemoteDatabase._privateConstructor();

  static final RemoteDatabase _object = RemoteDatabase._privateConstructor();

  factory RemoteDatabase() {
    return _object;
  }

  FirebaseFirestore _database = FirebaseFirestore.instance;

  String _booksCollectionName = "books";
  String _chaptersCollectionName = "chapters";

  Future<String> createBook(Book book) async {
    await _database
        .collection(_booksCollectionName)
        .doc()
        .set(book.toMap());
    return "";
  }

  Future<List<dynamic>> readAllBooks(
    String userId,
    int categoryId,
    DocumentSnapshot<Map<String, dynamic>>? lastBookDocument,
    int dataCountToRetrieve,
  ) async {
    List<Book> books = [];

    Query<Map<String, dynamic>> query = _database
        .collection(_booksCollectionName)
        .where("userId", isEqualTo: userId);

    if (categoryId != -1) {
      query = query.where("category", isEqualTo: categoryId);
    } else {
      query = query.orderBy("category", descending: true);
    }

    query = query.orderBy("name").limit(dataCountToRetrieve);

    if (lastBookDocument != null) {
      query = query.startAfterDocument(lastBookDocument);
    }

    QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();

    if (snapshot.docs.isNotEmpty) {
      for (DocumentSnapshot<Map<String, dynamic>> document in snapshot.docs) {
        Map<String, dynamic>? bookMap = document.data();
        bookMap?["id"] = document.id;
        if (bookMap != null) {
          Book book = Book.fromMap(bookMap);
          books.add(book);
        }
      }
      lastBookDocument = snapshot.docs.last;
    }
    return [books, lastBookDocument];
  }

  Future<int> updateBook(Book book) async {
    Map<String, dynamic> fieldsToUpdate = {
      "name": book.name,
      "category": book.category,
      "image": book.image,
    };

    await _database
        .collection(_booksCollectionName)
        .doc(book.id)
        .update(fieldsToUpdate);

    return 1;
  }

  Future<int> deleteBook(Book book) async {
    await _database
        .collection(_booksCollectionName)
        .doc(book.id)
        .delete();
    return 1;
  }

  Future<int> deleteBooks(List<String> bookIds) async {
    WriteBatch batch = _database.batch();
    for (String bookId in bookIds) {
      batch.delete(
        _database.collection(_booksCollectionName).doc(bookId),
      );
    }
    await batch.commit();
    return bookIds.length;
  }

  Future<String> createChapter(Chapter chapter) async {
    await _database
        .collection(_booksCollectionName)
        .doc(chapter.bookId)
        .collection(_chaptersCollectionName)
        .doc()
        .set(chapter.toMap());
    return "";
  }

  Future<List<Chapter>> readAllChapters(String bookId) async {
    List<Chapter> chapters = [];

    QuerySnapshot<Map<String, dynamic>> snapshot = await _database
        .collection(_booksCollectionName)
        .doc(bookId)
        .collection(_chaptersCollectionName)
        .get();

    if (snapshot.docs.isNotEmpty) {
      for (DocumentSnapshot<Map<String, dynamic>> document in snapshot.docs) {
        Map<String, dynamic>? chapterMap = document.data();
        chapterMap?["id"] = document.id;
        if (chapterMap != null) {
          Chapter chapter = Chapter.fromMap(chapterMap);
          chapters.add(chapter);
        }
      }
    }
    return chapters;
  }

  Future<int> updateChapter(Chapter chapter) async {
    Map<String, dynamic> fieldsToUpdate = {
      "title": chapter.title,
      "content": chapter.content,
    };

    await _database
        .collection(_booksCollectionName)
        .doc(chapter.bookId)
        .collection(_chaptersCollectionName)
        .doc(chapter.id)
        .update(fieldsToUpdate);

    return 1;
  }

  Future<int> deleteChapter(Chapter chapter) async {
    await _database
        .collection(_booksCollectionName)
        .doc(chapter.bookId)
        .collection(_chaptersCollectionName)
        .doc(chapter.id)
        .delete();

    return 1;
  }

  // Transaction
  /*
  Future<void> buyPremium(String userId) async {
    DocumentReference<Map<String, dynamic>> documentReferencePoint =
        _database.collection("points").doc(userId);

    DocumentReference<Map<String, dynamic>> documentReferenceSubscription =
        _database.collection("subscriptions").doc(userId);

    await _database.runTransaction((Transaction transaction) {
      return transaction
          .get<Map<String, dynamic>>(documentReferencePoint)
          .then((document) {
        Map<String, dynamic>? pointMap = document.data();

        if (pointMap != null) {
          int point = pointMap["point"];
          if (point > 1000) {
            transaction.update(documentReferenceSubscription, {"premium": true});
            transaction.update(documentReferencePoint, {"point": point - 1000});
          }
        }
      });
    });
  }
  */

  // Batched Writes
  /*
  Future<void> buyPremium(String userId) async {
    DocumentReference<Map<String, dynamic>> documentReferencePoint =
        _database.collection("points").doc(userId);

    DocumentReference<Map<String, dynamic>> documentReferenceSubscription =
        _database.collection("subscriptions").doc(userId);

    WriteBatch batch = _database.batch();
    batch.update(documentReferenceSubscription, {"premium": true});
    batch.update(documentReferencePoint, {"point": 0});
    await batch.commit();
  }
  */
}
