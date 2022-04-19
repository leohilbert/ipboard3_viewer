// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:ipboard3_viewer/posts_view.dart';
import 'package:ipboard3_viewer/routes.dart';
import 'package:ipboard3_viewer/topics_view.dart';
import 'package:ipboard3_viewer/utils.dart';
import 'package:go_router/go_router.dart';
import 'database.dart';

class MemberView extends StatefulWidget {
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
  State<MemberView> createState() => _MemberViewState();
}

class _MemberViewState extends State<MemberView>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  static int _index = 0;
  late TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(initialIndex: _index, length: 2, vsync: this);
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
              Tab(icon: Icon(Icons.notes)),
              Tab(icon: Icon(Icons.topic)),
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
          ],
        ));
  }

  @override
  bool get wantKeepAlive => true;
}
