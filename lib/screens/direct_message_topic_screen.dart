import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ipboard3_viewer/database/ipboard_database.dart';
import 'package:ipboard3_viewer/misc/utils.dart';
import 'package:ipboard3_viewer/views/posts_view.dart';

class DirectMessageTopicScreen extends StatelessWidget {
  final IpBoardDatabaseInterface database;
  final int fromId;
  final int toId;

  const DirectMessageTopicScreen({
    Key? key,
    required this.database,
    required this.fromId,
    required this.toId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var posts = database
        .getDirectMessages(fromId, toId)
        .onError(IpBoardViewerUtils.handleError);
    return Scaffold(
      appBar: AppBar(
        title: Text("DM"),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: IpBoardViewerUtils.buildFutureBuilder<List<PostRow>>(
        posts,
        (data) => PostsView(
          key: Key("postsForTopic-${fromId}-${toId}"),
          posts: data,
          didSelectPost: (value) async {
            context.push("/member/${value.authorId}");
          },
        ),
      ),
    );
  }
}
