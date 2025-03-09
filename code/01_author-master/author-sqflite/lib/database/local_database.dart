import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:author/model/chapter.dart';
import 'package:author/model/book.dart';

class LocalDatabase {
  LocalDatabase._privateConstructor();

  static final LocalDatabase _object = LocalDatabase._privateConstructor();

  factory LocalDatabase() {
    return _object;
  }

  Database? _database;

  String _booksTableName = "books";
  String _idBooks = "id";
  String _nameBooks = "name";
  String _createdDateBooks = "createdDate";
  String _categoryBooks = "category";

  String _chaptersTableName = "chapters";
  String _idChapters = "id";
  String _bookIdChapters = "bookId";
  String _titleChapters = "title";
  String _contentChapters = "content";
  String _createdDateChapters = "createdDate";

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

  Future<int> createBook(Book book) async {
    Database? db = await _getDatabase();
    if (db != null) {
      return await db.insert(_booksTableName, book.toMap());
    } else {
      return -1;
    }
  }

  Future<List<Book>> readAllBooks(
    int categoryId,
    int lastBookId,
    int dataCountToRetrieve,
  ) async {
    Database? db = await _getDatabase();
    List<Book> books = [];

    if (db != null) {
      String filter = "$_idBooks > ?";

      List<dynamic> filterArguments = [];
      filterArguments.add(lastBookId);

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
        Book b = Book.fromMap(m);
        books.add(b);
      }
    }
    return books;
  }

  Future<int> updateBook(Book book) async {
    Database? db = await _getDatabase();
    if (db != null) {
      return await db.update(
        _booksTableName,
        book.toMap(),
        where: "$_idBooks = ?",
        whereArgs: [book.id],
      );
    } else {
      return 0;
    }
  }

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

  Future<int> deleteBooks(List<int> bookIds) async {
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

  Future<int> createChapter(Chapter chapter) async {
    Database? db = await _getDatabase();
    if (db != null) {
      return await db.insert(_chaptersTableName, chapter.toMap());
    } else {
      return -1;
    }
  }

  Future<List<Chapter>> readAllChapters(int bookId) async {
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

  Future<int> updateChapter(Chapter chapter) async {
    Database? db = await _getDatabase();
    if (db != null) {
      return await db.update(
        _chaptersTableName,
        chapter.toMap(),
        where: "$_idChapters = ?",
        whereArgs: [chapter.id],
      );
    } else {
      return 0;
    }
  }

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
