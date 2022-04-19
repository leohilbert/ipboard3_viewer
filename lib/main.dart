import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:ipboard3_viewer/database.dart';
import 'package:ipboard3_viewer/forums_view.dart';
import 'package:ipboard3_viewer/member_view.dart';
import 'package:ipboard3_viewer/posts_view.dart';
import 'package:ipboard3_viewer/routes.dart';
import 'package:ipboard3_viewer/search_view.dart';
import 'package:ipboard3_viewer/topics_view.dart';
import 'package:ipboard3_viewer/utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //GestureBinding.instance!.resamplingEnabled = true;
  runApp(IpBoardViewerApp(database: await IpBoardDatabase.create(rootBundle)));
}

class IpBoardViewerApp extends StatelessWidget {
  final IpBoardDatabaseInterface database;

  IpBoardViewerApp({Key? key, required this.database}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'IPBoard3 Viewer',
      routeInformationParser: _router.routeInformationParser,
      routerDelegate: _router.routerDelegate,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }

  late final GoRouter _router = GoRouter(
    routes: <GoRoute>[
      GoRoute(
        name: Routes.main,
        path: '/',
        builder: (BuildContext context, GoRouterState state) => MainScreen(
          database: database,
        ),
      ),
      GoRoute(
        name: Routes.forum,
        path: '/forum/:fid',
        builder: (BuildContext context, GoRouterState state) {
          return IpBoardViewerUtils.buildFutureBuilder<ForumRow?>(
              database.getForum(int.parse(state.params['fid']!)),
                  (data) => ForumScreen(database: database, forum: data!));
        },
      ),
      GoRoute(
        name: Routes.topic,
        path: '/topic/:tid',
        builder: (BuildContext context, GoRouterState state) {
          return IpBoardViewerUtils.buildFutureBuilder<TopicRow?>(
              database.getTopic(int.parse(state.params['tid']!)),
                  (data) => TopicScreen(database: database, topic: data!));
        },
      ),
      GoRoute(
        name: Routes.member,
        path: '/member/:mid',
        builder: (BuildContext context, GoRouterState state) {
          return IpBoardViewerUtils.buildFutureBuilder<MemberRow?>(
              database.getMember(int.parse(state.params['mid']!)),
                  (data) => MemberScreen(database: database, member: data!));
        },
      ),
    ],
  );
}

class MainScreen extends StatelessWidget {
  final IpBoardDatabaseInterface database;

  const MainScreen({Key? key, required this.database}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future<List<ForumRow>> forums =
        database.getForums().onError(IpBoardViewerUtils.handleError);
    return Scaffold(
      appBar: AppBar(
        title: const Text('IPBoard'),
        actions: [
          IconButton(
            onPressed: () async {
              final result = await showSearch(
                context: context,
                delegate: SearchView(
                  (searchTerm) => database.searchMembers(searchTerm),
                ),
              );
              if (result != null) {
                context
                    .pushNamed(Routes.member, params: {'mid': "${result.id}"});
              }
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: IpBoardViewerUtils.buildFutureBuilder<List<ForumRow>>(
        forums,
        (data) => ForumsView(
          forums: data,
          didSelectForum: (forum) {
            context.pushNamed(Routes.forum, params: {'fid': "${forum.id}"});
          },
        ),
      ),
    );
  }
}

class ForumScreen extends StatelessWidget {
  final IpBoardDatabaseInterface database;
  final ForumRow forum;

  const ForumScreen({Key? key, required this.database, required this.forum})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var topics =
        database.getTopics(forum).onError(IpBoardViewerUtils.handleError);
    return Scaffold(
      appBar: AppBar(
        title: Text(forum.name),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: IpBoardViewerUtils.buildFutureBuilder<List<TopicRow>>(
        topics,
        (data) => TopicsView(
          key: Key("topicsForForum-${forum.id}"),
          topics: data,
          didSelectTopic: (topic) =>
              context.pushNamed(Routes.topic, params: {"tid": "${topic.id}"}),
        ),
      ),
    );
  }
}

class TopicScreen extends StatelessWidget {
  final IpBoardDatabaseInterface database;
  final TopicRow topic;

  const TopicScreen({Key? key, required this.database, required this.topic})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var posts =
        database.getPosts(topic).onError(IpBoardViewerUtils.handleError);
    return Scaffold(
      appBar: AppBar(
        title: Text(topic.title),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: IpBoardViewerUtils.buildFutureBuilder<List<PostRow>>(
        posts,
        (data) => PostsView(
          key: Key("postsForTopic-${topic.id}"),
          posts: data,
          didSelectPost: (value) async {
            context.push("/member/${value.authorId}");
          },
        ),
      ),
    );
  }
}

class MemberScreen extends StatelessWidget {
  final IpBoardDatabaseInterface database;
  final MemberRow member;

  const MemberScreen({Key? key, required this.database, required this.member})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var posts = database
        .getPostsFromMember(member)
        .onError(IpBoardViewerUtils.handleError);
    var topics = database
        .getTopicsFromMember(member)
        .onError(IpBoardViewerUtils.handleError);
    return MemberView(
      member: member,
      posts: posts,
      topics: topics,
    );
  }
}
