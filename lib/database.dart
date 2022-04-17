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
}

class ForumRow {
  int id;
  String name;
  String description;
  int parentId;

  ForumRow(this.id, this.name, this.description, this.parentId);
}
