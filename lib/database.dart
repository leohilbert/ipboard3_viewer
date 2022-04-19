import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:mysql1/mysql1.dart';

class IpBoardDatabase implements IpBoardDatabaseInterface {
  static const membersSelect =
      'select member_id, members_display_name, posts, email from members';

  final MySqlConnection _conn;
  var htmlUnescape = HtmlUnescape();

  static Future<IpBoardDatabaseInterface> create(AssetBundle rootBundle) async {
    try {
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
    } catch (e, stackTrace) {
      debugPrint("Can't load access.json. Returning Mock! $e");
      debugPrintStack(stackTrace: stackTrace);
      return IpBoardDatabaseMock();
    }
  }

  IpBoardDatabase(this._conn);

  @override
  Future<ForumRow?> getForum(int id) async {
    Results result = await _conn.query(
        'select id, name, description, parent_id from forums where id=?', [id]);
    if (result.isNotEmpty) return _parseForumRow(result.first);
    return null;
  }

  @override
  Future<List<ForumRow>> getForums() async {
    List<ForumRow> rows = [];
    Results parents = await _conn.query(
        'select id, name, description, parent_id from forums where parent_id=-1 order by position asc');
    for (ForumRow parentRow in parents.map(_parseForumRow)) {
      rows.add(parentRow);
      Results children = await _conn.query(
          'select id, name, description, posts from forums where parent_id=? order by position asc',
          [parentRow.id]);
      rows.addAll(children.map(_parseForumRow));
    }
    return rows;
  }

  @override
  Future<List<TopicRow>> getTopics(ForumRow forum) async {
    Results topics = await _conn.query(
        'select tid, title, posts, starter_name, start_date from topics where forum_id=? order by last_post desc',
        [forum.id]);
    return topics.map(_parseTopicRow).toList();
  }

  @override
  Future<TopicRow?> getTopic(int topicId) async {
    Results result = await _conn.query(
      'select tid, title, posts, starter_name, start_date from topics where tid=? order by last_post desc',
      [topicId],
    );
    if (result.isNotEmpty) return _parseTopicRow(result.first);
    return null;
  }

  @override
  Future<List<TopicRow>> getTopicsFromMember(MemberRow member) async {
    Results topics = await _conn.query(
        'select tid, title, posts, starter_name, start_date from topics where starter_id=? order by start_date desc',
        [member.id]);
    return topics.map(_parseTopicRow).toList();
  }

  @override
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

  @override
  Future<List<PostRow>> getPostsFromMember(MemberRow member) async {
    Results posts = await _conn.query(
        'select pid, author_name, post_date, post, topic_id, author_id, topics.title from posts '
        'left join topics on posts.topic_id=topics.tid '
        'where author_id=? order by post_date desc',
        [member.id]);
    return posts
        .map((row) => PostRow(row[0], "${row[1]}", row[2],
            htmlUnescape.convert("${row[3]}"), row[4], row[5], row[6]))
        .toList();
  }

  @override
  Future<List<MemberRow>> searchMembers(String searchTerm) async {
    Results members = await _conn.query(
        '$membersSelect where name like ? '
        'or email like ? '
        'or members_display_name like ?',
        ["%$searchTerm%", "%$searchTerm%", "%$searchTerm%"]);
    return members.map(_parseMemberRow).toList();
  }

  @override
  Future<MemberRow?> getMember(int id) async {
    Results result =
        await _conn.query('$membersSelect where member_id=?', [id]);
    if (result.isEmpty) return null;
    return _parseMemberRow(result.first);
  }

  ForumRow _parseForumRow(ResultRow row) {
    return ForumRow(row[0], row[1], "${row[2]}", row[3]);
  }

  TopicRow _parseTopicRow(ResultRow row) =>
      TopicRow(row[0], htmlUnescape.convert(row[1]), row[2], row[3], row[4]);

  MemberRow _parseMemberRow(ResultRow row) =>
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
  int startDate;

  TopicRow(
      this.id, this.title, this.postCount, this.starterName, this.startDate);
}

class ForumRow {
  int id;
  String name;
  String description;
  int parentId;

  ForumRow(this.id, this.name, this.description, this.parentId);
}

class IpBoardDatabaseMock implements IpBoardDatabaseInterface {
  @override
  Future<ForumRow> getForum(int id) {
    return toFuture(ForumRow(id, "Forum $id", "Description $id", 0));
  }

  @override
  Future<List<ForumRow>> getForums() {
    List<ForumRow> back = [];
    back.add(ForumRow(0, "Main", "", -1));
    for (int i = 1; i < 100; i++) {
      back.add(ForumRow(i, "Forum $i", "Description $i", 0));
    }
    return toFuture(back);
  }

  @override
  Future<MemberRow?> getMember(int id) {
    return toFuture(MemberRow(id, "User $id", 123, "$id@aol.de"));
  }

  @override
  Future<List<PostRow>> getPosts(TopicRow topic) {
    List<PostRow> back = [];
    for (int i = 0; i < 100; i++) {
      back.add(PostRow(
          i,
          "User $i",
          1650285761 + i * 2000,
          "Ich finde $i ist die schönste Zahl der Welt.",
          topic.id,
          i,
          "Hallo Welt $i"));
    }
    return toFuture(back);
  }

  @override
  Future<List<PostRow>> getPostsFromMember(MemberRow member) {
    List<PostRow> back = [];
    for (int i = 0; i < 100; i++) {
      back.add(PostRow(
          i,
          "User $i",
          1650285761 + i * 2000,
          "Ich finde $i ist die schönste Zahl der Welt.",
          i,
          member.id,
          "Hallo Welt $i"));
    }
    return toFuture(back);
  }

  @override
  Future<List<TopicRow>> getTopics(ForumRow forum) {
    List<TopicRow> back = [];
    for (int i = 0; i < 100; i++) {
      back.add(
          TopicRow(i, "Topic $i", i * 10, "User $i", 1650285761 + i * 2000));
    }
    return toFuture(back);
  }

  @override
  Future<TopicRow?> getTopic(int topicId) {
    return toFuture(TopicRow(
        topicId, "Topic $topicId", topicId * 10, "User $topicId", 1650285761));
  }

  @override
  Future<List<TopicRow>> getTopicsFromMember(MemberRow member) {
    List<TopicRow> back = [];
    for (int i = 0; i < 100; i++) {
      back.add(
          TopicRow(i, "Topic $i", i * 10, member.name, 1650285761 + i * 2000));
    }
    return toFuture(back);
  }

  @override
  Future<List<MemberRow>> searchMembers(String searchTerm) {
    List<MemberRow> back = [];
    for (int id = 0; id < 100; id++) {
      back.add(MemberRow(id, "User $id", 123, "$id@aol.de"));
    }
    return toFuture(back);
  }

  Future<T> toFuture<T>(T forums) {
    var completer = Completer<T>();
    completer.complete(forums);
    return completer.future;
  }
}

abstract class IpBoardDatabaseInterface {
  Future<List<ForumRow>> getForums();

  Future<ForumRow?> getForum(int id);

  Future<List<TopicRow>> getTopics(ForumRow forum);

  Future<TopicRow?> getTopic(int topicId);

  Future<List<TopicRow>> getTopicsFromMember(MemberRow member);

  Future<List<PostRow>> getPosts(TopicRow topic);

  Future<List<PostRow>> getPostsFromMember(MemberRow member);

  Future<List<MemberRow>> searchMembers(String searchTerm);

  Future<MemberRow?> getMember(int id);
}
