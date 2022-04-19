import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ipboard3_viewer/database/ipboard_database.dart';
import 'package:ipboard3_viewer/misc/utils.dart';
import 'package:ipboard3_viewer/views/posts_view.dart';

class TopicScreen extends StatelessWidget {
  final IpBoardDatabaseInterface database;
  final TopicRow topic;
  final int? scrollToPostId;

  const TopicScreen({
    Key? key,
    required this.database,
    required this.topic,
    this.scrollToPostId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var posts =
        database.getPosts(topic).onError(IpBoardViewerUtils.handleError);
    return Scaffold(
      appBar: AppBar(
        title: Text(topic.title),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: IpBoardViewerUtils.buildFutureBuilder<List<PostRow>>(
        posts,
        (data) => PostsView(
          key: Key("postsForTopic-${topic.id}"),
          posts: data,
          scrollToPostId: scrollToPostId,
          didSelectPost: (value) async {
            context.push("/member/${value.authorId}");
          },
        ),
      ),
    );
  }
}
