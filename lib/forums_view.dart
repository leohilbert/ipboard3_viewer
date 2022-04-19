import 'package:flutter/material.dart';
import 'package:ipboard3_viewer/utils.dart';

import 'database.dart';

class ForumsView extends StatelessWidget {
  static const valueKey = ValueKey("ForumsView");
  final List<ForumRow> forums;
  final ValueChanged<ForumRow> didSelectForum;

  const ForumsView(
      {Key? key, required this.forums, required this.didSelectForum})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      key: const PageStorageKey<String>('forumView'),
      controller: IpBoardViewerUtils.getFastScrollController(),
      itemCount: forums.length,
      itemBuilder: (context, index) {
        ForumRow row = forums.elementAt(index);
        if (row.parentId == -1) {
          return ListTile(
              title: Text(
            row.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ));
        }
        return Card(
          child: ListTile(
            onTap: () => didSelectForum(row),
            title: Text(
              row.name,
            ),
            subtitle: Text(row.description),
          ),
        );
      },
    );
  }
}
