import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skillsly_ma/src/core/localization/string_hardcoded.dart';
import 'package:skillsly_ma/src/core/routing/route_paths.dart';

import '../../../../core/routing/main_drawer.dart';
import '../../../../core/routing/routes.dart';

class SearchScreen extends StatefulWidget {
  SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'.hardcoded),
        actions: <Widget>[
          IconButton(
            onPressed: () => GoRouter.of(context).goNamed(Routes.searchUser),
            icon: Icon(Icons.search),
          )
        ],
      ),
      drawer: const MainDrawer(),
    );
  }
}
