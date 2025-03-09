import 'package:author/model/chapter.dart';
import 'package:author/model/book.dart';

abstract class DatabaseBase {
  Future<dynamic> createBook(Book book);

  Future<List<dynamic>> readAllBooks(
    dynamic userId,
    int categoryId,
    dynamic lastBook,
    int dataCountToRetrieve,
  );

  Future<int> updateBook(Book book);

  Future<int> deleteBook(Book book);

  Future<int> deleteBooks(List<dynamic> bookIds);

  Future<dynamic> createChapter(Chapter chapter);

  Future<List<Chapter>> readAllChapters(
    dynamic userId,
    dynamic bookId,
  );

  Future<int> updateChapter(Chapter chapter);

  Future<int> deleteChapter(Chapter chapter);
}
