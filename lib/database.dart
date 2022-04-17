import 'dart:convert';

import 'package:flutter/src/services/asset_bundle.dart';
import 'package:mysql1/mysql1.dart';

class IpBoardDatabase {
  MySqlConnection _conn;

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
    convertRow(ResultRow row) {
      return ForumRow(row[0], row[1], "${row[2]}", row[3]);
    }

    List<ForumRow> rows = [];
    Results parents = await _conn.query(
        'select id, name, description, parent_id from forums where parent_id=-1 order by position');
    for (ForumRow parentRow in parents.map(convertRow)) {
      rows.add(parentRow);
      Results children = await _conn.query(
          'select id, name, description, posts from forums where parent_id=${parentRow.id} order by position');
      rows.addAll(children.map(convertRow));
    }
    return rows;
    //return results.map((row) => ForumRow(row[0], row[1], "${row[2]}", row[3])).toList();
  }

  Future<List<TopicRow>> getTopics(ForumRow forum) async {
    Results topics = await _conn.query(
        'select tid, title, posts, starter_name from topics where forum_id=${forum.id} order by last_post desc');
    return topics.map((row) => TopicRow(row[0], row[1], row[2], row[3])).toList();
  }

  Future<List<PostRow>> getPosts(TopicRow topic) async {
    Results posts = await _conn.query(
        'select pid, author_name, post_date, post from posts where topic_id=${topic.id} order by post_date asc');
    return posts.map((row) => PostRow(row[0], "${row[1]}", row[2], "${row[3]}")).toList();
  }
}

class PostRow {
  int id;
  String author;
  int postDate;
  String post;

  PostRow(this.id, this.author, this.postDate, this.post);
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
