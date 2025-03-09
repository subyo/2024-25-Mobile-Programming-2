import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:author/model/chapter.dart';
import 'package:author/view_model/chapters_view_model.dart';

class ChaptersPage extends StatefulWidget {
  @override
  _ChaptersPageState createState() => _ChaptersPageState();
}

class _ChaptersPageState extends State<ChaptersPage> {
  @override
  Widget build(BuildContext context) {
    ChaptersViewModel viewModel = Provider.of<ChaptersViewModel>(
      context,
      listen: false,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(viewModel.book.name),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          viewModel.addChapter(context);
        },
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return _buildListView();
  }

  Widget _buildListView() {
    return Consumer<ChaptersViewModel>(
      builder: (context, viewModel, child) => ListView.builder(
        itemCount: viewModel.chapters.length,
        itemBuilder: (BuildContext context, int index) {
          return ChangeNotifierProvider.value(
            value: viewModel.chapters[index],
            child: _buildListTile(context, index),
          );
        },
      ),
    );
  }

  Widget _buildListTile(BuildContext context, int index) {
    return ListTile(
      leading: CircleAvatar(
        child: Consumer<Chapter>(
          builder: (context, chapter, child) => Text(chapter.id.toString()),
        ),
      ),
      title: Consumer<Chapter>(
        builder: (context, chapter, child) => Text(chapter.title),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              ChaptersViewModel viewModel = Provider.of<ChaptersViewModel>(
                context,
                listen: false,
              );
              viewModel.updateChapter(context, index);
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              ChaptersViewModel viewModel = Provider.of<ChaptersViewModel>(
                context,
                listen: false,
              );
              viewModel.deleteChapter(index);
            },
          ),
        ],
      ),
      onTap: () {
        ChaptersViewModel viewModel = Provider.of<ChaptersViewModel>(
          context,
          listen: false,
        );
        viewModel.openChapterDetailPage(context, index);
      },
    );
  }
}
