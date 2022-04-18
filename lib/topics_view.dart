import 'package:flutter/material.dart';
import 'package:ipboard3_viewer/utils.dart';

import 'database.dart';

class TopicsView extends StatelessWidget {
  static const valueKey = ValueKey("TopicsView");
  final List<TopicRow> topics;
  final ValueChanged<TopicRow> didSelectTopic;

  const TopicsView(
      {Key? key, required this.topics, required this.didSelectTopic})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      controller: IpBoardViewerUtils.getFastScrollController(),
      itemCount: topics.length,
      itemBuilder: (context, index) {
        TopicRow row = topics.elementAt(index);
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
    );
  }
}
