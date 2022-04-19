import 'package:flutter/material.dart';
import 'package:ipboard3_viewer/misc/utils.dart';

import '../database/ipboard_database.dart';

class DirectMessageTopicsView extends StatelessWidget {
  final List<DirectMessageTopicRow> topics;
  final ValueChanged<DirectMessageTopicRow> didSelectTopic;

  const DirectMessageTopicsView({
    Key? key,
    required this.topics,
    required this.didSelectTopic,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      key: PageStorageKey<String>(key.toString()),
      controller: IpBoardViewerUtils.getFastScrollController(),
      itemCount: topics.length,
      itemBuilder: (context, index) {
        DirectMessageTopicRow row = topics.elementAt(index);
        return Card(
          child: ListTile(
            onTap: () => didSelectTopic(row),
            title: Text(
              row.title,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(IpBoardViewerUtils.parseUnixDate(row.startDate)),
                Text("Posts: ${row.postCount}"),
              ],
            ),
          ),
        );
      },
    );
  }
}
