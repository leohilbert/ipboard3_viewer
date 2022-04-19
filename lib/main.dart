import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:ipboard3_viewer/database/ipboard_database.dart';
import 'package:ipboard3_viewer/misc/utils.dart';
import 'package:ipboard3_viewer/routes.dart';
import 'package:ipboard3_viewer/screens/direct_message_topic_screen.dart';
import 'package:ipboard3_viewer/screens/forum_screen.dart';
import 'package:ipboard3_viewer/screens/main_screen.dart';
import 'package:ipboard3_viewer/screens/member_screen.dart';
import 'package:ipboard3_viewer/screens/topic_screen.dart';

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
            database
                .getForum(int.parse(state.params['fid']!))
                .onError(IpBoardViewerUtils.handleError),
            (data) => ForumScreen(database: database, forum: data!),
          );
        },
      ),
      GoRoute(
        name: Routes.topic,
        path: '/topic/:tid',
        builder: (BuildContext context, GoRouterState state) {
          String? postId = state.queryParams['pid'];
          int? scrollToPostId = postId != null ? int.parse(postId) : null;

          return IpBoardViewerUtils.buildFutureBuilder<TopicRow?>(
            database
                .getTopic(int.parse(state.params['tid']!))
                .onError(IpBoardViewerUtils.handleError),
            (data) => TopicScreen(
              database: database,
              topic: data!,
              scrollToPostId: scrollToPostId,
            ),
          );
        },
      ),
      GoRoute(
        name: Routes.directMessageTopic,
        path: '/directMessageTopic/:fromId/:toId',
        builder: (BuildContext context, GoRouterState state) {
          int fromId = int.parse(state.params['fromId']!);
          int toId = int.parse(state.params['toId']!);
          debugPrint("$fromId -> $toId -> !!");
          return DirectMessageTopicScreen(
            database: database,
            fromId: fromId,
            toId: toId,
          );
        },
      ),
      GoRoute(
        name: Routes.member,
        path: '/member/:mid',
        builder: (BuildContext context, GoRouterState state) {
          return IpBoardViewerUtils.buildFutureBuilder<MemberRow?>(
            database
                .getMember(int.parse(state.params['mid']!))
                .onError(IpBoardViewerUtils.handleError),
            (data) => MemberScreen(database: database, member: data!),
          );
        },
      ),
    ],
  );
}
