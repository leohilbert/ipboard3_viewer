import 'package:flutter/material.dart';

import 'database.dart';

class TopicsView extends StatelessWidget {
  static const valueKey = ValueKey("TopicsView");
  final List<TopicRow> topics;
  final ValueChanged didSelectTopic;

  const TopicsView(
      {Key? key, required this.topics, required this.didSelectTopic})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: ListView(
        scrollDirection: Axis.vertical,
        children: topics.map(
          (row) {
            return Card(
              child: ListTile(
                onTap: () => didSelectTopic(row),
                title: Text(
                  row.title,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(row.starterName),
                    Text("Posts: ${row.postCount}"),
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
