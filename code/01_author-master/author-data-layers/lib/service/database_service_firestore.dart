import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:author/model/chapter.dart';
import 'package:author/model/book.dart';
import 'package:author/service/base/database_service.dart';

class FirestoreDatabaseService implements DatabaseService {
  final FirebaseFirestore _database = FirebaseFirestore.instance;

  final String _booksCollectionName = "books";
  final String _chaptersCollectionName = "chapters";

  @override
  Future createBook(Book book) async {
    Map<String, dynamic> bookMap = book.toMap();
    bookMap["createdDate"] = FieldValue.serverTimestamp();

    await _database.collection(_booksCollectionName).doc().set(bookMap);
    return "";
  }

  @override
  Future<List> readAllBooks(
    userId,
    int categoryId,
    lastBook,
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

    if (lastBook != null) {
      query = query.startAfterDocument(lastBook);
    }

    QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();

    if (snapshot.docs.isNotEmpty) {
      for (DocumentSnapshot<Map<String, dynamic>> document in snapshot.docs) {
        Map<String, dynamic>? bookMap = document.data();
        bookMap?["id"] = document.id;
        bookMap?["createdDate"] =
            (bookMap["createdDate"] as Timestamp).toDate();

        if (bookMap != null) {
          Book book = Book.fromMap(bookMap);
          books.add(book);
        }
      }
      lastBook = snapshot.docs.last;
    }
    return [books, lastBook];
  }

  @override
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

  @override
  Future<int> deleteBook(Book book) async {
    await _database.collection(_booksCollectionName).doc(book.id).delete();
    return 1;
  }

  @override
  Future<int> deleteBooks(List bookIds) async {
    WriteBatch batch = _database.batch();
    for (String bookId in bookIds) {
      batch.delete(
        _database.collection(_booksCollectionName).doc(bookId),
      );
    }
    await batch.commit();
    return bookIds.length;
  }

  @override
  Future createChapter(Chapter chapter) async {
    Map<String, dynamic> chapterMap = chapter.toMap();
    chapterMap["createdDate"] = FieldValue.serverTimestamp();

    await _database
        .collection(_booksCollectionName)
        .doc(chapter.bookId)
        .collection(_chaptersCollectionName)
        .doc()
        .set(chapterMap);
    return "";
  }

  @override
  Future<List<Chapter>> readAllChapters(userId, bookId) async {
    List<Chapter> chapters = [];

    QuerySnapshot<Map<String, dynamic>> snapshot = await _database
        .collection(_booksCollectionName)
        .doc(bookId)
        .collection(_chaptersCollectionName)
        .where("userId", isEqualTo: userId)
        .where("bookId", isEqualTo: bookId)
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

  @override
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

  @override
  Future<int> deleteChapter(Chapter chapter) async {
    await _database
        .collection(_booksCollectionName)
        .doc(chapter.bookId)
        .collection(_chaptersCollectionName)
        .doc(chapter.id)
        .delete();

    return 1;
  }
}
