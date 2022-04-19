import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ipboard3_viewer/database/ipboard_database.dart';
import 'package:ipboard3_viewer/misc/utils.dart';
import 'package:ipboard3_viewer/routes.dart';
import 'package:ipboard3_viewer/views/topics_view.dart';

class ForumScreen extends StatelessWidget {
  final IpBoardDatabaseInterface database;
  final ForumRow forum;

  const ForumScreen({Key? key, required this.database, required this.forum})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var topics =
        database.getTopics(forum).onError(IpBoardViewerUtils.handleError);
    return Scaffold(
      appBar: AppBar(
        title: Text(forum.name),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: IpBoardViewerUtils.buildFutureBuilder<List<TopicRow>>(
        topics,
        (data) => TopicsView(
          key: Key("topicsForForum-${forum.id}"),
          topics: data,
          didSelectTopic: (topic) => context.pushNamed(
            Routes.topic,
            params: {"tid": "${topic.id}"},
          ),
        ),
      ),
    );
  }
}
