import 'dart:io';

import 'package:author/constants.dart';
import 'package:author/database/local_database.dart';
import 'package:author/database/remote_database.dart';
import 'package:author/model/book.dart';
import 'package:author/view/chapters_page.dart';
import 'package:author/view/login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

class BooksPage extends StatefulWidget {
  @override
  _BooksPageState createState() => _BooksPageState();
}

class _BooksPageState extends State<BooksPage> {
  LocalDatabase _localDatabase = LocalDatabase();
  RemoteDatabase _remoteDatabase = RemoteDatabase();

  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseStorage _storage = FirebaseStorage.instance;

  List<Book> _books = [];
  DocumentSnapshot<Map<String, dynamic>>? _lastBookDocument;

  List<int> _allCategories = [-1];
  int _chosenCategory = -1;

  List<String> _chosenBookIds = [];

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
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              _logout(context);
            },
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
      leading: SizedBox(
        width: 48,
        height: 48,
        child: Image.network(
          _books[index].image ??
              "https://firebasestorage.googleapis.com"
                  "/v0/b/author-bfafa.appspot.com/o"
                  "/flutter_logo.jpg?alt=media&token="
                  "f6224659-ba88-4fef-a079-64e4253c3b47",
          fit: BoxFit.cover,
        ),
      ),
      title: Text(_books[index].name),
      subtitle: Text(Constants.categories[_books[index].category] ?? ""),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.add_a_photo),
            onPressed: () {
              _addImage(context, index);
            },
          ),
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
                  String? bookId = _books[index].id;
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
    String? userId = _auth.currentUser?.uid;

    if (userId != null) {
      List<dynamic> result =
          await _openDialog(context, "Enter Book Name") ?? [];

      if (result.isNotEmpty) {
        String bookName = result[0];
        int category = result[1];

        if (bookName.isNotEmpty) {
          Book newBook = Book(
            bookName,
            DateTime.now(),
            category,
            userId,
          );
          dynamic bookId = await _remoteDatabase.createBook(newBook);
          debugPrint("Book Id: " + bookId.toString());
          _books = [];
          setState(() {});
        }
      }
    }
  }

  Future<void> _getInitialBooks() async {
    if (_books.length == 0) {
      String? userId = _auth.currentUser?.uid;

      if (userId != null) {
        List<dynamic> dataRetrieved = await _remoteDatabase.readAllBooks(
          userId,
          _chosenCategory,
          null,
          10,
        );
        _books = dataRetrieved[0];
        _lastBookDocument = dataRetrieved[1];
        _printBookList("Initial books retrieved");
      }
    }
  }

  Future<void> _getNextBooks() async {
    String? userId = _auth.currentUser?.uid;

    if (userId != null) {
      List<dynamic> dataRetrieved = await _remoteDatabase.readAllBooks(
        userId,
        _chosenCategory,
        _lastBookDocument,
        10,
      );
      List<Book> nextBooks = dataRetrieved[0];
      _lastBookDocument = dataRetrieved[1];
      _books.addAll(nextBooks);
      _printBookList("Next books retrieved");
      setState(() {});
    }
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
        int updatedRowCount = await _remoteDatabase.updateBook(book);
        if (updatedRowCount > 0) {
          setState(() {});
        }
      }
    }
  }

  void _deleteBook(int index) async {
    Book book = _books[index];
    int deletedRowCount = await _remoteDatabase.deleteBook(book);
    if (deletedRowCount > 0) {
      _books = [];
      setState(() {});
    }
  }

  void _deleteChosenBooks() async {
    int deletedRowCount = await _remoteDatabase.deleteBooks(_chosenBookIds);
    if (deletedRowCount > 0) {
      _books = [];
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

  void _logout(BuildContext context) async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
    _openLoginPage(context);
  }

  void _openLoginPage(BuildContext context) {
    MaterialPageRoute pageRoute = MaterialPageRoute(
      builder: (BuildContext context) {
        return LoginPage();
      },
    );
    Navigator.pushReplacement(context, pageRoute);
  }

  _openChaptersPage(BuildContext context, int index) {
    MaterialPageRoute pageRoute = MaterialPageRoute(
      builder: (BuildContext context) {
        return ChaptersPage(_books[index]);
      },
    );
    Navigator.push(context, pageRoute);
  }

  void _addImage(BuildContext context, int index) async {
    ImagePicker imagePicker = ImagePicker();
    XFile? chosenFile = await imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (chosenFile != null) {
      File file = File(chosenFile.path);

      Book book = _books[index];
      String fileName = book.id;
      TaskSnapshot uploadTask = await _storage
          .ref("books/$fileName.jpg")
          .putFile(file);
      String fileUrl = await uploadTask.ref.getDownloadURL();

      book.image = fileUrl;
      await _remoteDatabase.updateBook(book);
    }
  }
}
