import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:ipboard3_viewer/utils.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import 'bb_code_converter.dart';
import 'database.dart';

class PostsView extends StatelessWidget {
  static const valueKey = ValueKey("PostsView");
  final List<PostRow> posts;
  final ValueChanged<PostRow> didSelectPost;
  final bool memberView;
  final int? scrollToPostId;

  const PostsView({
    Key? key,
    required this.posts,
    required this.didSelectPost,
    this.memberView = false,
    this.scrollToPostId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = AutoScrollController(
      axis: Axis.vertical,
      suggestedRowHeight: 200,
    );
    IpBoardViewerUtils.addFastControllerListener(controller);

    if (scrollToPostId != null) {
      debugPrint("scroll to $scrollToPostId");
      controller.scrollToIndex(
        scrollToPostId!,
        preferPosition: AutoScrollPosition.begin,
      );
      controller.highlight(scrollToPostId!);
    }
    return ListView.builder(
      key: PageStorageKey<String>(key.toString()),
      shrinkWrap: true,
      controller: controller,
      itemCount: posts.length,
      itemBuilder: (context, index) {
        PostRow row = posts.elementAt(index);
        return AutoScrollTag(
          key: ValueKey(row.id),
          controller: controller,
          index: row.id,
          child: _getRow(row),
        );
      },
    );
  }

  Widget _getRow(PostRow row) {
    var card = Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 4.0, 0.0, 4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton(
              child: Text(
                memberView ? row.topicName : row.authorName,
                textScaleFactor: 1.5,
              ),
              onPressed: () => didSelectPost(row),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
              child: Text(IpBoardViewerUtils.parseUnixDate(row.postDate)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
              child: buildHtmlPanel(row),
            ),
          ],
        ),
      ),
    );
    if (scrollToPostId == row.id) {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.green, width: 4),
        ),
        child: card,
      );
    }
    return card;
  }

  Widget buildHtmlPanel(PostRow row) {
    String parsed = parsePost(row);
    var threshold = 500;
    if (parsed.length > threshold) {
      return ExpandablePanel(
        header: const Align(
          alignment: Alignment.centerLeft,
          child: Icon(Icons.arrow_circle_down),
        ),
        collapsed: SelectableHtml(data: parsed.substring(0, threshold)),
        expanded: SelectableHtml(data: parsed),
      );
    } else {
      return SelectableHtml(data: parsed);
    }
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
