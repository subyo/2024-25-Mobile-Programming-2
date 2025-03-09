import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:author/model/chapter.dart';
import 'package:author/model/book.dart';
import 'package:author/service/base/database_service.dart';

class SqfliteDatabaseService implements DatabaseService {
  Database? _database;

  final String _booksTableName = "books";
  final String _idBooks = "id";
  final String _nameBooks = "name";
  final String _createdDateBooks = "createdDate";
  final String _categoryBooks = "category";

  final String _chaptersTableName = "chapters";
  final String _idChapters = "id";
  final String _bookIdChapters = "bookId";
  final String _titleChapters = "title";
  final String _contentChapters = "content";
  final String _createdDateChapters = "createdDate";

  Future<Database?> _getDatabase() async {
    if (_database == null) {
      String filePath = await getDatabasesPath();
      String databasePath = join(filePath, "author.db");
      _database = await openDatabase(
        databasePath,
        version: 3,
        onCreate: _createTable,
        onUpgrade: _updateTable,
      );
    }
    return _database;
  }

  Future<void> _createTable(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_booksTableName (
      $_idBooks INTEGER NOT NULL UNIQUE PRIMARY KEY AUTOINCREMENT,
      $_nameBooks TEXT NOT NULL,
      $_createdDateBooks INTEGER,
      $_categoryBooks INTEGER DEFAULT 0);
    ''');
    await db.execute('''
      CREATE TABLE $_chaptersTableName (
      $_idChapters INTEGER NOT NULL UNIQUE PRIMARY KEY AUTOINCREMENT,
      $_bookIdChapters INTEGER NOT NULL,
      $_titleChapters TEXT NOT NULL,
      $_contentChapters TEXT,
      $_createdDateChapters TEXT DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY("$_bookIdChapters") REFERENCES "$_booksTableName"("$_idBooks") ON DELETE CASCADE ON UPDATE CASCADE);
    ''');
  }

  Future<void> _updateTable(Database db, int oldVersion, int newVersion) async {
    List<String> updateCommands = [
      "ALTER TABLE $_booksTableName ADD COLUMN $_categoryBooks INTEGER DEFAULT 0",
      "ALTER TABLE $_booksTableName ADD COLUMN test INTEGER DEFAULT 0",
    ];
    for (int i = oldVersion - 1; i < newVersion - 1; i++) {
      await db.execute(updateCommands[i]);
    }
  }

  @override
  Future createBook(Book book) async {
    Database? db = await _getDatabase();
    if (db != null) {
      Map<String, dynamic> bookMap = book.toMap();
      bookMap["createdDate"] = book.createdDate.millisecondsSinceEpoch;
      bookMap.remove("userId");
      bookMap.remove("image");

      return await db.insert(_booksTableName, bookMap);
    } else {
      return -1;
    }
  }

  @override
  Future<List> readAllBooks(
    userId,
    int categoryId,
    lastBook,
    int dataCountToRetrieve,
  ) async {
    Database? db = await _getDatabase();
    List<Book> books = [];

    if (db != null) {
      String filter = "$_idBooks > ?";

      List<dynamic> filterArguments = [];
      filterArguments.add(lastBook ?? 0);

      if (categoryId >= 0) {
        filter += " and $_categoryBooks = ?";
        filterArguments.add(categoryId);
      }

      List<Map<String, dynamic>> booksMap = await db.query(
        _booksTableName,
        where: filter,
        whereArgs: filterArguments,
        limit: dataCountToRetrieve,
      );

      for (Map<String, dynamic> m in booksMap) {
        Map<String, dynamic> bookMap = Map.of(m);
        bookMap["createdDate"] = DateTime.fromMillisecondsSinceEpoch(
          bookMap["createdDate"],
        );
        Book b = Book.fromMap(bookMap);
        books.add(b);
      }
      if (books.isNotEmpty) {
        lastBook = books.last.id;
      }
    }
    return [books, lastBook];
  }

  @override
  Future<int> updateBook(Book book) async {
    Database? db = await _getDatabase();
    if (db != null) {
      Map<String, dynamic> bookMap = book.toMap();
      bookMap["createdDate"] = book.createdDate.millisecondsSinceEpoch;
      bookMap.remove("userId");
      bookMap.remove("image");

      return await db.update(
        _booksTableName,
        bookMap,
        where: "$_idBooks = ?",
        whereArgs: [book.id],
      );
    } else {
      return 0;
    }
  }

  @override
  Future<int> deleteBook(Book book) async {
    Database? db = await _getDatabase();
    if (db != null) {
      return await db.delete(
        _booksTableName,
        where: "$_idBooks = ?",
        whereArgs: [book.id],
      );
    } else {
      return 0;
    }
  }

  @override
  Future<int> deleteBooks(List bookIds) async {
    Database? db = await _getDatabase();
    if (db != null && bookIds.length > 0) {
      String filter = "$_idBooks in (";

      for (int i = 0; i < bookIds.length; i++) {
        if (i != bookIds.length - 1) {
          filter += "?,";
        } else {
          filter += "?)";
        }
      }

      return await db.delete(
        _booksTableName,
        where: filter,
        whereArgs: bookIds,
      );
    } else {
      return 0;
    }
  }

  @override
  Future createChapter(Chapter chapter) async {
    Database? db = await _getDatabase();
    if (db != null) {
      Map<String, dynamic> chapterMap = chapter.toMap();
      chapterMap["createdDate"] = DateTime.now().millisecondsSinceEpoch;
      chapterMap.remove("userId");

      return await db.insert(_chaptersTableName, chapterMap);
    } else {
      return -1;
    }
  }

  @override
  Future<List<Chapter>> readAllChapters(userId, bookId) async {
    Database? db = await _getDatabase();
    List<Chapter> chapters = [];

    if (db != null) {
      List<Map<String, dynamic>> chaptersMap = await db.query(
        _chaptersTableName,
        where: "$_bookIdChapters = ?",
        whereArgs: [bookId],
      );

      for (Map<String, dynamic> m in chaptersMap) {
        Chapter c = Chapter.fromMap(m);
        chapters.add(c);
      }
    }
    return chapters;
  }

  @override
  Future<int> updateChapter(Chapter chapter) async {
    Database? db = await _getDatabase();
    if (db != null) {
      Map<String, dynamic> chapterMap = chapter.toMap();
      chapterMap.remove("createdDate");
      chapterMap.remove("userId");

      return await db.update(
        _chaptersTableName,
        chapterMap,
        where: "$_idChapters = ?",
        whereArgs: [chapter.id],
      );
    } else {
      return 0;
    }
  }

  @override
  Future<int> deleteChapter(Chapter chapter) async {
    Database? db = await _getDatabase();
    if (db != null) {
      return await db.delete(
        _chaptersTableName,
        where: "$_idChapters = ?",
        whereArgs: [chapter.id],
      );
    } else {
      return 0;
    }
  }
}
