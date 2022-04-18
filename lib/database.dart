import 'dart:convert';

import 'package:flutter/src/services/asset_bundle.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:mysql1/mysql1.dart';

class IpBoardDatabase {
  static const membersSelect =
      'select member_id, members_display_name, posts, email from members';

  final MySqlConnection _conn;
  var htmlUnescape = HtmlUnescape();

  static Future<IpBoardDatabase> create(AssetBundle rootBundle) async {
    final contents = await rootBundle.loadString(
      'assets/config/access.json',
    );
    final json = jsonDecode(contents);
    var connectionSettings = ConnectionSettings(
        host: json['host'],
        port: json['port'],
        user: json['user'],
        password: json['password'],
        db: json['db']);
    var conn = await MySqlConnection.connect(connectionSettings);
    return IpBoardDatabase(conn);
  }

  IpBoardDatabase(this._conn);

  Future<List<ForumRow>> getForums() async {
    List<ForumRow> rows = [];
    Results parents = await _conn.query(
        'select id, name, description, parent_id from forums where parent_id=-1 order by position');
    for (ForumRow parentRow in parents.map(parseForumRow)) {
      rows.add(parentRow);
      Results children = await _conn.query(
          'select id, name, description, posts from forums where parent_id=? order by position',
          [parentRow.id]);
      rows.addAll(children.map(parseForumRow));
    }
    return rows;
  }

  Future<List<TopicRow>> getTopics(ForumRow forum) async {
    Results topics = await _conn.query(
        'select tid, title, posts, starter_name from topics where forum_id=? order by last_post desc',
        [forum.id]);
    return topics.map(parseTopicRow).toList();
  }

  Future<List<PostRow>> getPosts(TopicRow topic) async {
    Results posts = await _conn.query(
        'select pid, author_name, post_date, post, topic_id, author_id from posts '
        'where topic_id=? order by post_date asc',
        [topic.id]);
    return posts
        .map((row) => PostRow(row[0], "${row[1]}", row[2],
            htmlUnescape.convert("${row[3]}"), row[4], row[5], topic.title))
        .toList();
  }

  Future<List<PostRow>> getPostsFromMember(MemberRow member) async {
    Results posts = await _conn.query(
        'select pid, author_name, post_date, post, topic_id, author_id, topics.title from posts '
        'left join topics on posts.topic_id=topics.tid '
        'where author_id=? order by post_date asc',
        [member.id]);
    return posts
        .map((row) => PostRow(row[0], "${row[1]}", row[2],
            htmlUnescape.convert("${row[3]}"), row[4], row[5], row[6]))
        .toList();
  }

  Future<List<MemberRow>> searchMembers(String searchTerm) async {
    Results members = await _conn.query(
        '$membersSelect where name like ? '
        'or email like ? '
        'or members_display_name like ?',
        ["%$searchTerm%", "%$searchTerm%", "%$searchTerm%"]);
    return members.map(parseMemberRow).toList();
  }

  Future<MemberRow?> getMember(int id) async {
    Results result =
        await _conn.query('$membersSelect where member_id=?', [id]);
    if (result.isEmpty) return null;
    return parseMemberRow(result.first);
  }

  ForumRow parseForumRow(ResultRow row) {
    return ForumRow(row[0], row[1], "${row[2]}", row[3]);
  }

  TopicRow parseTopicRow(ResultRow row) =>
      TopicRow(row[0], htmlUnescape.convert(row[1]), row[2], row[3]);

  MemberRow parseMemberRow(ResultRow row) =>
      MemberRow(row[0], "${row[1]}", row[2], "${row[3]}");
}

class MemberRow {
  int id;
  String name;
  int posts;
  String email;

  MemberRow(this.id, this.name, this.posts, this.email);
}

class PostRow {
  int id;
  String authorName;
  String topicName;
  int authorId;
  int postDate;
  String post;
  int topicId;

  PostRow(this.id, this.authorName, this.postDate, this.post, this.topicId,
      this.authorId, this.topicName);
}

class TopicRow {
  int id;
  String title;
  int postCount;
  String starterName;

  TopicRow(this.id, this.title, this.postCount, this.starterName);
}

class ForumRow {
  int id;
  String name;
  String description;
  int parentId;

  ForumRow(this.id, this.name, this.description, this.parentId);
}
