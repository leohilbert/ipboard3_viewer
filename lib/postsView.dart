import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:ipboard3_viewer/utils.dart';

import 'bb_code_converter.dart';
import 'database.dart';

class PostsView extends StatelessWidget {
  static const valueKey = ValueKey("PostsView");
  final List<PostRow> posts;
  final ValueChanged<PostRow> didSelectPost;
  final bool memberView;

  const PostsView(
      {Key? key,
      required this.posts,
      required this.didSelectPost,
      this.memberView = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: IpBoardViewerUtils.getFastScrollController(),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        PostRow row = posts.elementAt(index);
        return Card(
          child: ListTile(
            onTap: () => didSelectPost(row),
            title: Text(
              memberView ? row.topicName : row.authorName,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(DateFormat('dd.MM.yy HH:mm:ss').format(
                    DateTime.fromMillisecondsSinceEpoch(row.postDate * 1000))),
                Html(data: parsePost(row)),
              ],
            ),
          ),
        );
      },
    );
  }

  String parsePost(PostRow row) {
    try {
      return BBCodeConverter().parse(row.post);
    } catch (_) {
      debugPrint("error parsing post");
    }
    return row.post;
  }
}
