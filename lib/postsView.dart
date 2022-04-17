import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import 'database.dart';

class PostsView extends StatelessWidget {
  static const valueKey = ValueKey("PostsView");
  final List<PostRow> posts;

  const PostsView(
      {Key? key, required this.posts})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: ListView(
        scrollDirection: Axis.vertical,
        children: posts.map(
          (row) {
            return Card(
              child: ListTile(
                //onTap: () => didSelectTopic(row),
                title: Text(
                  row.author,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${row.postDate}"),
                    Html(data: row.post),
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
