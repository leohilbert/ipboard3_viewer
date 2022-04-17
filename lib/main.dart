import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:ipboard3_viewer/database.dart';
import 'package:ipboard3_viewer/forumsView.dart';
import 'package:ipboard3_viewer/postsView.dart';
import 'package:ipboard3_viewer/topicsView.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(IpBoardViewer(db: await IpBoardDatabase.create(rootBundle)));
}

class IpBoardViewer extends StatefulWidget {
  final IpBoardDatabase _db;

  const IpBoardViewer({Key? key, required IpBoardDatabase db})
      : _db = db,
        super(key: key);

  @override
  State<IpBoardViewer> createState() => _IpBoardViewerState();
}

class _IpBoardViewerState extends State<IpBoardViewer> {
  ForumRow? _selectedForum;
  TopicRow? _selectedTopic;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'IPBoard3 Viewer',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Navigator(
          pages: [
            buildForumsView(),
            if (_selectedForum != null) buildTopicsView(_selectedForum!),
            if (_selectedTopic != null) buildPostsView(_selectedTopic!),
          ],
          onPopPage: (route, result) {
            final page = route.settings as MaterialPage;
            if (page.key == TopicsView.valueKey) {
              _selectedForum = null;
            } else if (page.key == PostsView.valueKey) {
              _selectedTopic = null;
            }
            return route.didPop(result);
          },
        ));
  }

  MaterialPage buildForumsView() {
    Future<List<ForumRow>> forums = widget._db.getForums().onError(handleError);
    return MaterialPage(
      key: ForumsView.valueKey,
      child: Scaffold(
        appBar: AppBar(title: const Text('IPBoard')),
        body: buildFutureBuilder<List<ForumRow>>(
          forums,
          (data) => ForumsView(
            forums: data,
            didSelectForum: (forum) {
              setState(() => _selectedForum = forum);
            },
          ),
        ),
      ),
    );
  }

  MaterialPage buildTopicsView(ForumRow forum) {
    var topics = widget._db.getTopics(forum).onError(handleError);
    return MaterialPage(
      key: TopicsView.valueKey,
      child: Scaffold(
        appBar: AppBar(title: Text(forum.name)),
        body: buildFutureBuilder<List<TopicRow>>(
          topics,
          (data) => TopicsView(
            topics: data,
            didSelectTopic: (topic) => setState(() => _selectedTopic = topic),
          ),
        ),
      ),
    );
  }

  MaterialPage buildPostsView(TopicRow topic) {
    var posts = widget._db.getPosts(topic).onError(handleError);
    return MaterialPage(
      key: PostsView.valueKey,
      child: Scaffold(
        appBar: AppBar(title: Text(topic.title)),
        body: buildFutureBuilder<List<PostRow>>(
          posts,
          (data) => PostsView(
            posts: data,
          ),
        ),
      ),
    );
  }

  FutureBuilder<D> buildFutureBuilder<D>(
      Future<D> future, Widget Function(D data) toElement) {
    return FutureBuilder<D>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Text("ERROR: ${snapshot.error}");
          }
          return toElement(snapshot.data!);
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  FutureOr<T> handleError<T>(Object error, StackTrace stackTrace) {
    debugPrint("$error");
    debugPrintStack(stackTrace: stackTrace);
    throw error;
  }
}
