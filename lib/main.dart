import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ipboard3_viewer/database.dart';
import 'package:ipboard3_viewer/forums_view.dart';
import 'package:ipboard3_viewer/member_view.dart';
import 'package:ipboard3_viewer/posts_view.dart';
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

  const IpBoardViewerApp({Key? key, required this.database}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IPBoard3 Viewer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: IpBoardViewerScreen(database: database),
    );
  }
}

class IpBoardViewerScreen extends StatefulWidget {
  final IpBoardDatabaseInterface database;

  const IpBoardViewerScreen({Key? key, required this.database})
      : super(key: key);

  @override
  State<IpBoardViewerScreen> createState() => _IpBoardViewerScreenState();
}

class _IpBoardViewerScreenState extends State<IpBoardViewerScreen> {
  ForumRow? _selectedForum;
  TopicRow? _selectedTopic;
  MemberRow? _selectedMember;

  //bool _inSearch;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      pages: [
        buildForumsView(context),
        if (_selectedForum != null) buildTopicsView(_selectedForum!),
        if (_selectedTopic != null) buildPostsView(_selectedTopic!),
        if (_selectedMember != null) buildMemberView(_selectedMember!),
        //if(_inSearch) ,
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
    );
  }

  MaterialPage buildForumsView(BuildContext context) {
    Future<List<ForumRow>> forums =
        widget.database.getForums().onError(IpBoardViewerUtils.handleError);
    return MaterialPage(
      key: ForumsView.valueKey,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('IPBoard'),
          actions: [
            IconButton(
              onPressed: () async {
                final result = await showSearch(
                  context: context,
                  delegate: SearchView(
                    (searchTerm) => widget.database.searchMembers(searchTerm),
                  ),
                );
                if (result != null) {
                  setState(() {
                    _selectedMember = result;
                  });
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
              setState(() => _selectedForum = forum);
            },
          ),
        ),
      ),
    );
  }

  MaterialPage buildTopicsView(ForumRow forum) {
    var topics = widget.database
        .getTopics(forum)
        .onError(IpBoardViewerUtils.handleError);
    return MaterialPage(
      key: TopicsView.valueKey,
      child: Scaffold(
        appBar: AppBar(title: Text(forum.name)),
        body: IpBoardViewerUtils.buildFutureBuilder<List<TopicRow>>(
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
    var posts =
        widget.database.getPosts(topic).onError(IpBoardViewerUtils.handleError);
    return MaterialPage(
      key: PostsView.valueKey,
      child: Scaffold(
        appBar: AppBar(title: Text(topic.title)),
        body: IpBoardViewerUtils.buildFutureBuilder<List<PostRow>>(
          posts,
          (data) => PostsView(
            posts: data,
            didSelectPost: (value) async {
              _selectedMember = await widget.database.getMember(value.authorId);
            },
          ),
        ),
      ),
    );
  }

  MaterialPage buildMemberView(MemberRow member) {
    var posts = widget.database
        .getPostsFromMember(member)
        .onError(IpBoardViewerUtils.handleError);
    return MaterialPage(
      key: MemberView.valueKey,
      child: Scaffold(
        appBar: AppBar(title: Text(member.name)),
        body: IpBoardViewerUtils.buildFutureBuilder<List<PostRow>>(
          posts,
          (data) => MemberView(
            posts: data,
          ),
        ),
      ),
    );
  }
}
