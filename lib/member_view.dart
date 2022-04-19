// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:ipboard3_viewer/posts_view.dart';
import 'package:ipboard3_viewer/routes.dart';
import 'package:ipboard3_viewer/topics_view.dart';
import 'package:ipboard3_viewer/utils.dart';
import 'package:go_router/go_router.dart';
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
              bottom: TabBar(
                key: PageStorageKey<Type>(TabBar),
                tabs: const [
                  Tab(icon: Icon(Icons.notes)),
                  Tab(icon: Icon(Icons.topic)),
                ],
              ),
            ),
            body: TabBarView(
              key: PageStorageKey<Type>(TabBarView),
              children: [
                IpBoardViewerUtils.buildFutureBuilder<List<PostRow>>(
                  posts,
                  (data) => PostsView(
                    key: Key("postsForMember-${member.id}"),
                    posts: data,
                    memberView: true,
                    didSelectPost: (value) {
                      context.pushNamed(
                        Routes.topic,
                        params: {"tid": "${value.topicId}"},
                        queryParams: {'pid': "${value.id}"},
                      );
                    },
                  ),
                ),
                IpBoardViewerUtils.buildFutureBuilder<List<TopicRow>>(
                  topics,
                  (data) => TopicsView(
                    key: Key("topicsForMember-${member.id}"),
                    topics: data,
                    didSelectTopic: (value) {
                      context.pushNamed(
                        Routes.topic,
                        params: {"tid": "${value.id}"},
                      );
                    },
                  ),
                ),
              ],
            )));
  }
}
