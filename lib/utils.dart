import 'dart:async';

import 'package:flutter/material.dart';

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
}