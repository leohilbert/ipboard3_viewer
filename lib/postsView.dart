import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:ipboard3_viewer/bbCodeConverter.dart';

import 'database.dart';

class PostsView extends StatelessWidget {
  static const valueKey = ValueKey("PostsView");
  final List<PostRow> posts;
  final ValueChanged<PostRow> didSelectPost;

  const PostsView({Key? key, required this.posts, required this.didSelectPost})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: ListView(
        scrollDirection: Axis.vertical,
        children: posts.map(
          (row) {
            var dateTime =
                DateTime.fromMillisecondsSinceEpoch(row.postDate * 1000);
            var postHtml = row.post;
            try {
              postHtml = BBCodeConverter().parse(row.post);
            } on Exception {
              debugPrint("error parsing post");
            }
            return Card(
              child: ListTile(
                onTap: () => didSelectPost(row),
                title: Text(
                  row.authorName,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(DateFormat('dd.MM.yy HH:mm:ss').format(dateTime)),
                    Html(data: postHtml),
                  ],
                ),
              ),
            );
          },
        ).toList(),
      ),
    );
  }
}
