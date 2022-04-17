import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:ipboard3_viewer/database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(IpBoardViewer(db: await IpBoardDatabase.create(rootBundle)));
}

class IpBoardViewer extends StatelessWidget {
  final IpBoardDatabase _db;

  const IpBoardViewer({Key? key, required IpBoardDatabase db})
      : _db = db,
        super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Future<List<ForumRow>> forums = _db.getForums().onError(handleError);
    return MaterialApp(
      title: 'IPBoard3 Viewer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: buildForumView(forums),
      ),
    );
  }

  FutureBuilder<List<ForumRow>> buildForumView(Future<List<ForumRow>> forums) {
    return buildFutureBuilder(
      forums,
      (data) => Scrollbar(
        child: ListView(
          scrollDirection: Axis.vertical,
          children: data.map(
            (row) {
              if (row.parentId == -1) {
                return ListTile(
                    title: Text(
                  row.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ));
              }
              return Card(
                child: ListTile(
                  title: Text(
                    row.name,
                  ),
                  subtitle: Text(row.description),
                ),
              );
            },
          ).toList(),
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

  FutureOr<List<ForumRow>> handleError(Object error, StackTrace stackTrace) {
    debugPrint("$error");
    debugPrintStack(stackTrace: stackTrace);
    throw error;
  }
}
