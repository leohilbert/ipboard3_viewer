import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ipboard3_viewer/database/ipboard_database.dart';
import 'package:ipboard3_viewer/misc/utils.dart';
import 'package:ipboard3_viewer/routes.dart';
import 'package:ipboard3_viewer/views/posts_view.dart';
import 'package:ipboard3_viewer/views/topics_view.dart';

import '../database/ipboard_database.dart';

class MemberView extends StatefulWidget {
  static const valueKey = ValueKey("MemberView");
  final Future<List<PostRow>> posts;
  final Future<List<TopicRow>> topics;
  final Future<List<TopicRow>> directMessageTopics;
  final MemberRow member;

  const MemberView({
    Key? key,
    required this.member,
    required this.posts,
    required this.topics,
    required this.directMessageTopics,
  }) : super(key: key);

  @override
  State<MemberView> createState() => _MemberViewState();
}

class _MemberViewState extends State<MemberView>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  static int _index = 0;
  late TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(initialIndex: _index, length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.member.name),
          bottom: TabBar(
            controller: _controller,
            tabs: const [
              Tab(icon: Icon(Icons.message)),
              Tab(icon: Icon(Icons.topic)),
              Tab(icon: Icon(Icons.person_add)),
            ],
            onTap: (int index) {
              _index = index;
            },
          ),
        ),
        body: TabBarView(
          controller: _controller,
          children: [
            IpBoardViewerUtils.buildFutureBuilder<List<PostRow>>(
              widget.posts,
              (data) => PostsView(
                key: Key("postsForMember-${widget.member.id}"),
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
              widget.topics,
              (data) => TopicsView(
                key: Key("topicsForMember-${widget.member.id}"),
                topics: data,
                didSelectTopic: (value) {
                  context.pushNamed(
                    Routes.topic,
                    params: {"tid": "${value.id}"},
                  );
                },
              ),
            ),
            IpBoardViewerUtils.buildFutureBuilder<List<TopicRow>>(
              widget.directMessageTopics,
              (data) => TopicsView(
                key: Key("directMessageTopicsForMember-${widget.member.id}"),
                topics: data,
                didSelectTopic: (value) {
                  context.pushNamed(
                    Routes.directMessageTopic,
                    params: {"mtid": "${value.id}"},
                  );
                },
              ),
            ),
          ],
        ));
  }

  @override
  bool get wantKeepAlive => true;
}
