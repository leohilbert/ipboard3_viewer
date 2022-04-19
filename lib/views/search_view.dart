import 'package:flutter/material.dart';
import 'package:ipboard3_viewer/misc/utils.dart';

import '../database/ipboard_database.dart';

class SearchView extends SearchDelegate<MemberRow?> {
  Future<List<MemberRow>> Function(String searchTerm) memberSearchProvider;

  SearchView(this.memberSearchProvider);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }

  @override
  Widget buildResults(BuildContext context) {
    Future<List<MemberRow>> future = memberSearchProvider
        .call(query)
        .onError(IpBoardViewerUtils.handleError);
    return IpBoardViewerUtils.buildFutureBuilder<List<MemberRow>>(
      future,
      (data) => ListView.builder(
        key: const PageStorageKey<String>('searchView'),
        controller: IpBoardViewerUtils.getFastScrollController(),
        itemCount: data.length,
        itemBuilder: (context, index) {
          MemberRow row = data.elementAt(index);
          return ListTile(
            onTap: () => close(context, row),
            title: Text(row.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(row.email),
                Text("${row.posts}"),
              ],
            ),
          );
        },
      ),
    );
  }
}
