import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skillsly_ma/src/core/localization/string_hardcoded.dart';

import '../../../../core/routing/main_drawer.dart';
import '../../../../core/routing/routes.dart';

class SearchUserScreen extends StatefulWidget {
  SearchUserScreen({Key? key}) : super(key: key);

  @override
  State<SearchUserScreen> createState() => _SearchUserScreenState();
}

class _SearchUserScreenState extends State<SearchUserScreen> {
  final userInputController = TextEditingController();

  void searchUsers() {
    print(userInputController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
            width: double.infinity,
            height: 40,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(5)),
            child: Center(
              child: TextField(
                controller: userInputController,
                onSubmitted: (_) => searchUsers(),
                decoration: InputDecoration(
                    prefixIcon: IconButton(
                      icon: Icon(Icons.search),
                      onPressed: searchUsers,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          userInputController.text = '';
                        });
                      },
                    ),
                    hintText: 'Busca un usuario',
                    border: InputBorder.none),
              ),
            )),
      ),
      drawer: const MainDrawer(),
    );
  }
}
