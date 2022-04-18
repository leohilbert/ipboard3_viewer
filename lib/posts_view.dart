import 'package:expandable/expandable.dart';
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
      shrinkWrap: true,
      controller: IpBoardViewerUtils.getFastScrollController(),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        PostRow row = posts.elementAt(index);
        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton(
                child: Text(
                  memberView ? row.topicName : row.authorName,
                  textScaleFactor: 2,
                ),
                onPressed: () => didSelectPost(row),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
                child: Text(parseUnixDate(row)),
              ),
              buildHtmlPanel(row),
            ],
          ),
        );
      },
    );
  }

  Widget buildHtmlPanel(PostRow row) {
    String parsed = parsePost(row);
    var threshold = 500;
    if (parsed.length > threshold) {
      return ExpandablePanel(
        header: const Padding(
          padding: EdgeInsets.fromLTRB(8.0, 0, 0, 0),
          child: Align(
              alignment: Alignment.centerLeft,
              child: Icon(Icons.arrow_circle_down)),
        ),
        collapsed: Html(data: parsed.substring(0, threshold)),
        expanded: Html(data: parsed),
      );
    } else {
      return Html(data: parsed);
    }
  }

  String parseUnixDate(PostRow row) {
    return DateFormat('dd.MM.yy HH:mm:ss')
        .format(DateTime.fromMillisecondsSinceEpoch(row.postDate * 1000));
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
