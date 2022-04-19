
import 'dart:async';

import 'ipboard_database.dart';

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

  @override
  Future<List<TopicRow>> getDirectMessageTopics(MemberRow member) {
    List<TopicRow> back = [];
    for (int i = 0; i < 100; i++) {
      back.add(
          TopicRow(i, "Topic $i", i * 10, member.name, 1650285761 + i * 2000));
    }
    return toFuture(back);
  }

  @override
  Future<List<PostRow>> getDirectMessages(TopicRow topic) {
    List<PostRow> back = [];
    for (int i = 0; i < 100; i++) {
      back.add(PostRow(
          i,
          "User $i",
          1650285761 + i * 2000,
          "Ich finde $i ist die schönste Zahl der Welt.",
          i,
          topic.id,
          "Hallo Welt $i"));
    }
    return toFuture(back);
  }

  @override
  Future<TopicRow?> getDirectMessageTopic(int id) {
return  toFuture(TopicRow(id, "Topic $id", id * 10, "abc", 0));
  }

  Future<T> toFuture<T>(T forums) {
    var completer = Completer<T>();
    completer.complete(forums);
    return completer.future;
  }
}