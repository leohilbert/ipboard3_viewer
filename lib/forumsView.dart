import 'package:flutter/material.dart';

import 'database.dart';

class ForumsView extends StatelessWidget {
  static const valueKey = ValueKey("ForumsView");
  final List<ForumRow> forums;
  final ValueChanged didSelectForum;

  const ForumsView({Key? key, required this.forums, required this.didSelectForum})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: ListView(
        scrollDirection: Axis.vertical,
        children: forums.map(
          (row) {
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
        ).toList(),
      ),
    );
  }
}
