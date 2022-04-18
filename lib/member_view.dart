import 'package:flutter/material.dart';
import 'package:ipboard3_viewer/posts_view.dart';
import 'package:ipboard3_viewer/topics_view.dart';
import 'package:ipboard3_viewer/utils.dart';

import 'database.dart';

class MemberView extends StatelessWidget {
  static const valueKey = ValueKey("MemberView");
  final Future<List<PostRow>> posts;
  final Future<List<TopicRow>> topics;
  final MemberRow member;

  const MemberView({
    Key? key,
    required this.posts,
    required this.topics,
    required this.member,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: AppBar(
              title: Text(member.name),
              bottom: const TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.notes)),
                  Tab(icon: Icon(Icons.topic)),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                IpBoardViewerUtils.buildFutureBuilder<List<PostRow>>(
                  posts,
                  (data) => PostsView(
                    posts: data,
                    memberView: true,
                    didSelectPost: (value) {},
                  ),
                ),
                IpBoardViewerUtils.buildFutureBuilder<List<TopicRow>>(
                  topics,
                  (data) => TopicsView(
                    topics: data,
                    didSelectTopic: (value) {},
                  ),
                ),
              ],
            )));
  }
}
