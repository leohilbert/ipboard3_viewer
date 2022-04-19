import 'package:flutter/material.dart';
import 'package:ipboard3_viewer/database/ipboard_database.dart';
import 'package:ipboard3_viewer/misc/utils.dart';
import 'package:ipboard3_viewer/views/member_view.dart';

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
    var directMessageTopics = database
        .getDirectMessageTopics(member)
        .onError(IpBoardViewerUtils.handleError);
    return MemberView(
      key: Key('member-${member.id}'),
      member: member,
      posts: posts,
      topics: topics,
      directMessageTopics: directMessageTopics,
    );
  }
}
