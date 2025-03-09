import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:author/view_model/chapter_detail_view_model.dart';

class ChapterDetailPage extends StatelessWidget {
  TextEditingController _contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    ChapterDetailViewModel viewModel = Provider.of<ChapterDetailViewModel>(
      context,
      listen: false,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(viewModel.chapter.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              viewModel.saveContent(_contentController.text.trim());
            },
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    ChapterDetailViewModel viewModel = Provider.of<ChapterDetailViewModel>(
      context,
      listen: false,
    );
    _contentController.text = viewModel.chapter.content;
    return Container(
      padding: EdgeInsets.all(16.0),
      child: TextField(
        controller: _contentController,
        maxLines: 1000,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
        ),
      ),
    );
  }
}
