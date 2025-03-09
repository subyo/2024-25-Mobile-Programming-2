import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:author/model/book.dart';
import 'package:author/constants.dart';
import 'package:author/view_model/books_view_model.dart';

class BooksPage extends StatefulWidget {
  @override
  State<BooksPage> createState() => _BooksPageState();
}

class _BooksPageState extends State<BooksPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Books Page"),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              BooksViewModel viewModel = Provider.of<BooksViewModel>(
                context,
                listen: false,
              );
              viewModel.deleteChosenBooks();
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              BooksViewModel viewModel = Provider.of<BooksViewModel>(
                context,
                listen: false,
              );
              viewModel.logout(context);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          BooksViewModel viewModel = Provider.of<BooksViewModel>(
            context,
            listen: false,
          );
          viewModel.addBook(context);
        },
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return _buildListView();
  }

  Widget _buildListView() {
    return Column(
      children: [
        _categoryFilter(),
        Expanded(
          child: Consumer<BooksViewModel>(
            builder: (context, viewModel, child) => ListView.builder(
              controller: viewModel.scrollController,
              itemCount: viewModel.books.length,
              itemBuilder: (BuildContext context, int index) {
                return ChangeNotifierProvider.value(
                  value: viewModel.books[index],
                  child: _buildListTile(context, index),
                );
              },
            ),
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
        child: Consumer<Book>(
          builder: (context, book, child) => Image.network(
            book.image ??
                "https://firebasestorage.googleapis.com"
                    "/v0/b/author-bfafa.appspot.com/o"
                    "/flutter_logo.jpg?alt=media&token="
                    "f6224659-ba88-4fef-a079-64e4253c3b47",
            fit: BoxFit.cover,
          ),
        ),
      ),
      title: Consumer<Book>(builder: (context, book, child) => Text(book.name)),
      subtitle: Consumer<Book>(
          builder: (context, book, child) =>
              Text(Constants.categories[book.category] ?? "")),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.add_a_photo),
            onPressed: () {
              BooksViewModel viewModel = Provider.of<BooksViewModel>(
                context,
                listen: false,
              );
              viewModel.addImage(context, index);
            },
          ),
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              BooksViewModel viewModel = Provider.of<BooksViewModel>(
                context,
                listen: false,
              );
              viewModel.updateBook(context, index);
            },
          ),
          Consumer<Book>(
            builder: (context, book, child) => Checkbox(
              value: book.isChosen,
              onChanged: (bool? newValue) {
                if (newValue != null) {
                  BooksViewModel viewModel = Provider.of<BooksViewModel>(
                    context,
                    listen: false,
                  );
                  viewModel.bookSelectionChanged(index, newValue);
                  book.isChosen = newValue;
                }
              },
            ),
          ),
        ],
      ),
      onTap: () {
        BooksViewModel viewModel = Provider.of<BooksViewModel>(
          context,
          listen: false,
        );
        viewModel.openChaptersPage(context, index);
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
        Consumer<BooksViewModel>(
          builder: (context, viewModel, child) => DropdownButton(
            value: viewModel.chosenCategory,
            onChanged: (int? newChosenCategory) {
              BooksViewModel viewModel = Provider.of<BooksViewModel>(
                context,
                listen: false,
              );
              viewModel.categorySelectionChanged(newChosenCategory);
            },
            items: viewModel.allCategories.map<DropdownMenuItem<int>>(
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
        ),
      ],
    );
  }
}
