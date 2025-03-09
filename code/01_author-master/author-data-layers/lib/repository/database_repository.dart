import 'package:author/base/database_base.dart';
import 'package:author/main.dart';
import 'package:author/model/chapter.dart';
import 'package:author/model/book.dart';
import 'package:author/service/base/database_service.dart';
import 'package:author/service/database_service_firestore.dart';

class DatabaseRepository implements DatabaseBase {
  final DatabaseService _service = locator<FirestoreDatabaseService>();

  @override
  Future createBook(Book book) async {
    return await _service.createBook(book);
  }

  @override
  Future<List> readAllBooks(
    userId,
    int categoryId,
    lastBook,
    int dataCountToRetrieve,
  ) async {
    return await _service.readAllBooks(
      userId,
      categoryId,
      lastBook,
      dataCountToRetrieve,
    );
  }

  @override
  Future<int> updateBook(Book book) async {
    return await _service.updateBook(book);
  }

  @override
  Future<int> deleteBook(Book book) async {
    return await _service.deleteBook(book);
  }

  @override
  Future<int> deleteBooks(List bookIds) async {
    return await _service.deleteBooks(bookIds);
  }

  @override
  Future createChapter(Chapter chapter) async {
    return await _service.createChapter(chapter);
  }

  @override
  Future<List<Chapter>> readAllChapters(userId, bookId) async {
    return await _service.readAllChapters(userId, bookId);
  }

  @override
  Future<int> updateChapter(Chapter chapter) async {
    return await _service.updateChapter(chapter);
  }

  @override
  Future<int> deleteChapter(Chapter chapter) async {
    return await _service.deleteChapter(chapter);
  }
}
