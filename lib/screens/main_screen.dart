import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ipboard3_viewer/database/ipboard_database.dart';
import 'package:ipboard3_viewer/misc/utils.dart';
import 'package:ipboard3_viewer/routes.dart';
import 'package:ipboard3_viewer/views/forums_view.dart';
import 'package:ipboard3_viewer/views/search_view.dart';

class MainScreen extends StatelessWidget {
  final IpBoardDatabaseInterface database;

  const MainScreen({Key? key, required this.database}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future<List<ForumRow>> forums =
        database.getForums().onError(IpBoardViewerUtils.handleError);
    return Scaffold(
      appBar: AppBar(
        title: const Text('IPBoard'),
        actions: [
          IconButton(
            onPressed: () async {
              final result = await showSearch(
                context: context,
                delegate: SearchView(
                  (searchTerm) => database.searchMembers(searchTerm),
                ),
              );
              if (result != null) {
                context
                    .pushNamed(Routes.member, params: {'mid': "${result.id}"});
              }
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: IpBoardViewerUtils.buildFutureBuilder<List<ForumRow>>(
        forums,
        (data) => ForumsView(
          forums: data,
          didSelectForum: (forum) {
            context.pushNamed(Routes.forum, params: {'fid': "${forum.id}"});
          },
        ),
      ),
    );
  }
}
