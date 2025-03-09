import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:author/model/book.dart';
import 'package:author/constants.dart';
import 'package:author/database/remote_database.dart';
import 'package:author/database/local_database.dart';
import 'package:author/view/chapters_page.dart';
import 'package:author/view/login_page.dart';
import 'package:author/view_model/chapters_view_model.dart';
import 'package:author/view_model/login_view_model.dart';

class BooksViewModel with ChangeNotifier {
  LocalDatabase _localDatabase = LocalDatabase();
  RemoteDatabase _remoteDatabase = RemoteDatabase();

  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseStorage _storage = FirebaseStorage.instance;

  List<Book> books = [];
  DocumentSnapshot<Map<String, dynamic>>? _lastBookDocument;

  List<int> allCategories = [-1];
  int _chosenCategory = -1;

  int get chosenCategory => _chosenCategory;

  set chosenCategory(int value) {
    _chosenCategory = value;
  }

  List<String> _chosenBookIds = [];

  ScrollController scrollController = ScrollController();

  BooksViewModel() {
    allCategories.addAll(Constants.categories.keys);
    scrollController.addListener(_scrollControl);
    _getBooks();
  }

  void _scrollControl() {
    if (scrollController.offset == scrollController.position.maxScrollExtent) {
      _getBooks();
    }
  }

  void addBook(BuildContext context) async {
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
          books = [];
          _lastBookDocument = null;
          _getBooks();
        }
      }
    }
  }

  Future<void> _getBooks() async {
    String? userId = _auth.currentUser?.uid;

    if (userId != null) {
      List<dynamic> dataRetrieved = await _remoteDatabase.readAllBooks(
        userId,
        _chosenCategory,
        _lastBookDocument,
        10,
      );
      List<Book> newBooks = dataRetrieved[0];
      books.addAll(newBooks);
      _lastBookDocument = dataRetrieved[1];
      _printBookList("Next books retrieved");
      notifyListeners();
    }
  }

  void updateBook(BuildContext context, int index) async {
    Book book = books[index];

    List<dynamic> result = await _openDialog(context, "Update Book",
            currentName: book.name, currentCategory: book.category) ??
        [];

    if (result.isNotEmpty) {
      String newBookName = result[0];
      int newCategory = result[1];

      if (newBookName != book.name || newCategory != book.category) {
        if (newBookName.isNotEmpty) {
          book.name = newBookName;
        }
        book.category = newCategory;
        int updatedRowCount = await _remoteDatabase.updateBook(book);
      }
    }
  }

  void deleteBook(int index) async {
    Book book = books[index];
    int deletedRowCount = await _remoteDatabase.deleteBook(book);
    if (deletedRowCount > 0) {
      books.removeAt(index);
      notifyListeners();
    }
  }

  void deleteChosenBooks() async {
    int deletedRowCount = await _remoteDatabase.deleteBooks(_chosenBookIds);
    if (deletedRowCount > 0) {
      books.removeWhere((k) => _chosenBookIds.contains(k.id));
      notifyListeners();
    }
  }

  Future<List<dynamic>?> _openDialog(BuildContext context, String title,
      {String currentName = "", int currentCategory = 0}) {
    TextEditingController nameController =
        TextEditingController(text: currentName);

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
                        items: Constants.categories.keys
                            .map<DropdownMenuItem<int>>(
                          (categoryId) {
                            return DropdownMenuItem<int>(
                              value: categoryId,
                              child:
                                  Text(Constants.categories[categoryId] ?? ""),
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

  void _printBookList(String initialMessage) {
    String bookNames = "";
    for (Book b in books) {
      bookNames += "${b.name}, ";
    }
    debugPrint("$initialMessage \n $bookNames");
  }

  openChaptersPage(BuildContext context, int index) {
    MaterialPageRoute pageRoute = MaterialPageRoute(
      builder: (BuildContext context) {
        return ChangeNotifierProvider(
          create: (BuildContext context) => ChaptersViewModel(books[index]),
          child: ChaptersPage(),
        );
      },
    );
    Navigator.push(context, pageRoute);
  }

  void logout(BuildContext context) async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
    _openLoginPage(context);
  }

  void _openLoginPage(BuildContext context) {
    MaterialPageRoute pageRoute = MaterialPageRoute(
      builder: (BuildContext context) {
        return ChangeNotifierProvider(
          create: (BuildContext context) => LoginViewModel(),
          child: LoginPage(),
        );
      },
    );
    Navigator.pushReplacement(context, pageRoute);
  }

  void addImage(BuildContext context, int index) async {
    ImagePicker imagePicker = ImagePicker();
    XFile? chosenFile = await imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (chosenFile != null) {
      File file = File(chosenFile.path);

      Book book = books[index];
      String fileName = book.id;
      TaskSnapshot uploadTask =
          await _storage.ref("books/$fileName.jpg").putFile(file);
      String fileUrl = await uploadTask.ref.getDownloadURL();

      book.image = fileUrl;
      await _remoteDatabase.updateBook(book);
    }
  }

  void bookSelectionChanged(int index, bool? newValue) {
    if (newValue != null) {
      String? bookId = books[index].id;
      if (bookId != null) {
        if (newValue) {
          _chosenBookIds.add(bookId);
        } else {
          _chosenBookIds.remove(books[index].id);
        }
      }
    }
  }

  void categorySelectionChanged(int? newChosenCategory) {
    books = [];
    _lastBookDocument = null;
    if (newChosenCategory != null) {
      chosenCategory = newChosenCategory;
      _getBooks();
    }
  }
}
