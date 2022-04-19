import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';

class IpBoardViewerUtils {
  static FutureBuilder<D> buildFutureBuilder<D>(
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

  static FutureOr<T> handleError<T>(Object error, StackTrace stackTrace) {
    debugPrint("$error");
    debugPrintStack(stackTrace: stackTrace);
    throw error;
  }

  static ScrollController getFastScrollController() {
    const _extraScrollSpeed = 200;
    var _scrollController = ScrollController();
    _scrollController.addListener(() {
      ScrollDirection scrollDirection =
          _scrollController.position.userScrollDirection;
      if (scrollDirection != ScrollDirection.idle) {
        double scrollEnd = _scrollController.offset +
            (scrollDirection == ScrollDirection.reverse
                ? _extraScrollSpeed
                : -_extraScrollSpeed);
        scrollEnd = min(_scrollController.position.maxScrollExtent,
            max(_scrollController.position.minScrollExtent, scrollEnd));
        _scrollController.jumpTo(scrollEnd);
      }
    });
    return _scrollController;
  }

  static String parseUnixDate(int unix) {
    return DateFormat('dd.MM.yy HH:mm:ss')
        .format(DateTime.fromMillisecondsSinceEpoch(unix * 1000));
  }
}
