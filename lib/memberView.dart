import 'package:flutter/material.dart';
import 'package:ipboard3_viewer/postsView.dart';

import 'database.dart';

class MemberView extends StatelessWidget {
  static const valueKey = ValueKey("MemberView");
  final List<PostRow> posts;

  const MemberView({Key? key, required this.posts}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PostsView(
      posts: posts,
      didSelectPost: (value) {

      },
    );
  }
}
