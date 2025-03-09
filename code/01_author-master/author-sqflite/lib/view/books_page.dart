import 'package:author/constants.dart';
import 'package:author/database/local_database.dart';
import 'package:author/model/book.dart';
import 'package:author/view/chapters_page.dart';
import 'package:flutter/material.dart';

class BooksPage extends StatefulWidget {
  @override
  _BooksPageState createState() => _BooksPageState();
}

class _BooksPageState extends State<BooksPage> {
  LocalDatabase _localDatabase = LocalDatabase();

  List<Book> _books = [];

  List<int> _allCategories = [-1];
  int _chosenCategory = -1;

  List<int> _chosenBookIds = [];

  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _allCategories.addAll(Constants.categories.keys);
    _scrollController.addListener(_scrollControl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Books Page"),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _deleteChosenBooks,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          _addBook(context);
        },
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return FutureBuilder<void>(
      future: _getInitialBooks(),
      builder: _buildListView,
    );
  }

  Widget _buildListView(BuildContext context, AsyncSnapshot<void> snapshot) {
    return Column(
      children: [
        _categoryFilter(),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: _books.length,
            itemBuilder: _buildListTile,
          ),
        ),
      ],
    );
  }

  Widget _buildListTile(BuildContext context, int index) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(_books[index].id.toString()),
      ),
      title: Text(_books[index].name),
      subtitle: Text(Constants.categories[_books[index].category] ?? ""),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              _updateBook(context, index);
            },
          ),
          Checkbox(
            value: _chosenBookIds.contains(_books[index].id),
            onChanged: (bool? newValue) {
              setState(() {
                if (newValue != null) {
                  int? bookId = _books[index].id;
                  if (bookId != null) {
                    if (newValue) {
                      _chosenBookIds.add(bookId);
                    } else {
                      _chosenBookIds.remove(bookId);
                    }
                  }
                }
              });
            },
          ),
        ],
      ),
      onTap: () {
        _openChaptersPage(context, index);
      },
    );
  }

  Widget _categoryFilter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          "Category:",
          style: TextStyle(fontSize: 16),
        ),
        DropdownButton(
          value: _chosenCategory,
          onChanged: (int? newChosenCategory) {
            if (newChosenCategory != null) {
              setState(() {
                _chosenCategory = newChosenCategory;
              });
            }
          },
          items: _allCategories.map<DropdownMenuItem<int>>(
                (categoryId) {
              return DropdownMenuItem<int>(
                value: categoryId,
                child: Text(categoryId == -1
                    ? "All"
                    : Constants.categories[categoryId] ?? ""),
              );
            },
          ).toList(),
        ),
      ],
    );
  }

  void _scrollControl() {
    if (_scrollController.offset ==
        _scrollController.position.maxScrollExtent) {
      _getNextBooks();
    }
  }

  void _addBook(BuildContext context) async {
    List<dynamic> result = await _openDialog(context, "Enter Book Name") ?? [];

    if (result.isNotEmpty) {
      String bookName = result[0];
      int category = result[1];

      if (bookName.isNotEmpty) {
        Book newBook = Book(bookName, DateTime.now(), category);
        int bookId = await _localDatabase.createBook(newBook);
        debugPrint("Book Id: " + bookId.toString());
        _books = [];
        setState(() {});
      }
    }
  }

  Future<void> _getInitialBooks() async {
    if (_books.length == 0) {
      _books = await _localDatabase.readAllBooks(
        _chosenCategory,
        0,
        10,
      );
      _printBookList("Initial books retrieved");
    }
  }

  Future<void> _getNextBooks() async {
    int? lastBookId = _books.last.id;

    if (lastBookId != null) {
      List<Book> nextBooks = await _localDatabase.readAllBooks(
        _chosenCategory,
        lastBookId,
        10,
      );
      _books.addAll(nextBooks);
      _printBookList("Next books retrieved");
      setState(() {});
    }
  }

  void _printBookList(String initialMessage) {
    String bookNames = "";
    for (Book b in _books) {
      bookNames += "${b.name}, ";
    }
    debugPrint("$initialMessage \n $bookNames");
  }

  void _updateBook(BuildContext context, int index) async {
    Book book = _books[index];

    List<dynamic> result = await _openDialog(context, "Update Book",
        currentName: book.name, currentCategory: book.category) ?? [];

    if (result.isNotEmpty) {
      String newBookName = result[0];
      int newCategory = result[1];

      if (newBookName != book.name || newCategory != book.category) {
        if (newBookName.isNotEmpty) {
          book.name = newBookName;
        }
        book.category = newCategory;
        int updatedRowCount = await _localDatabase.updateBook(book);
        if (updatedRowCount > 0) {
          setState(() {});
        }
      }
    }
  }

  void _deleteBook(int index) async {
    Book book = _books[index];
    int deletedRowCount = await _localDatabase.deleteBook(book);
    if (deletedRowCount > 0) {
      _books = [];
      setState(() {});
    }
  }

  void _deleteChosenBooks() async {
    int deletedRowCount = await _localDatabase.deleteBooks(_chosenBookIds);
    if (deletedRowCount > 0) {
      _books = [];
      setState(() {});
    }
  }

  Future<List<dynamic>?> _openDialog(BuildContext context, String title,
      {String currentName = "", int currentCategory = 0}) {

    TextEditingController nameController = TextEditingController(text: currentName);

    return showDialog<List<dynamic>>(
      context: context,
      builder: (context) {
        int category = currentCategory;
        return AlertDialog(
          title: Text(title),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    keyboardType: TextInputType.text,
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Category:"),
                      DropdownButton(
                        value: category,
                        onChanged: (int? newChosenCategory) {
                          if (newChosenCategory != null) {
                            setState(() {
                              category = newChosenCategory;
                            });
                          }
                        },
                        items: Constants.categories.keys.map<DropdownMenuItem<int>>(
                              (categoryId) {
                            return DropdownMenuItem<int>(
                              value: categoryId,
                              child: Text(Constants.categories[categoryId] ?? ""),
                            );
                          },
                        ).toList(),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.pop(context, []);
              },
            ),
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.pop(context, [nameController.text.trim(), category]);
              },
            ),
          ],
        );
      },
    );
  }

  _openChaptersPage(BuildContext context, int index) {
    MaterialPageRoute pageRoute = MaterialPageRoute(
      builder: (BuildContext context) {
        return ChaptersPage(_books[index]);
      },
    );
    Navigator.push(context, pageRoute);
  }
}
