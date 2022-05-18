import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skillsly_ma/src/core/constants/app.sizes.dart';
import 'package:skillsly_ma/src/core/routing/route_paths.dart';
import 'package:skillsly_ma/src/core/routing/routes.dart';
import 'package:skillsly_ma/src/features/account_settings/domain/user_account_details.dart';
import 'package:skillsly_ma/src/features/chat/data/chat_service.dart';
import 'package:skillsly_ma/src/features/users/data/search_service.dart';
import 'package:skillsly_ma/src/features/users/domain/search_user_details.dart';
import 'package:skillsly_ma/src/shared/types/pagination_details.dart';
import '../../../../core/routing/main_drawer.dart';

class SearchUserScreen extends ConsumerStatefulWidget {
  SearchUserScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SearchUserScreenState();
}

class _SearchUserScreenState extends ConsumerState<SearchUserScreen> {
  final userInputController = TextEditingController();
  ScrollController controller = ScrollController();

  List<SearchUserDetails> searchedUsers = [];
  bool _isLoadingUsers = true;
  bool _moreUsersToFetch = true;
  String previousInputControllerText = '';
  int limit = 9;
  int offset = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    controller.removeListener(_scrollListener);
    super.dispose();
  }

  Future<List<SearchUserDetails>> _getUsers() {
    final searchService = ref.read(searchServiceProvider);
    return searchService.searchUser(userInputController.text,
        PaginationDetails(limit: limit, offset: offset));
  }

  String get userInput {
    return userInputController.text;
  }

  void loadMoreUsers() async {
    List<SearchUserDetails> moreUsers = await _getUsers();
    if (moreUsers.isEmpty) {
      controller.removeListener(_scrollListener);
    } else {
      setState(() {
        searchedUsers.addAll(moreUsers);
        offset = offset + limit;
      });
    }
  }

  void searchUsers() async {
    if (previousInputControllerText != userInput) {
      controller = ScrollController()..addListener(_scrollListener);
      offset = 0;
      List<SearchUserDetails> users = await _getUsers();
      setState(() {
        searchedUsers = users;
        offset = limit + offset;
        previousInputControllerText = userInput;
      });
    }
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
        body: Container(
          child: (searchedUsers.length > 0
              ? ListView.builder(
                  controller: controller,
                  itemCount: searchedUsers.length,
                  itemBuilder: (ctx, index) {
                    return UserCard(searchedUsers[index]);
                  },
                )
              : Padding(
                  padding: const EdgeInsets.all(Sizes.p16),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "No se encontraron usuarios",
                          style: Theme.of(context).textTheme.headline4,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )),
        ));
  }

  void _scrollListener() {
    if (controller.position.extentAfter < 100) {
      setState(() {
        loadMoreUsers();
      });
    }
  }
}

class UserCard extends ConsumerWidget {
  UserCard(this.userInfo);

  final SearchUserDetails userInfo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        _showActionSheet(context, userInfo, ref);
      },
      child: Card(
        elevation: 2,
        child: ListTile(
          leading: const CircleAvatar(
              backgroundImage: NetworkImage(
                  'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg')),
          title: Text(userInfo.name),
          subtitle: Text(userInfo.email),
          // trailing: Column(
          //   children: [
          //     Expanded(
          //       child: TextButton(
          //         child: Text(
          //           'Seguir usuario',
          //           style: TextStyle(fontSize: 10),
          //         ),
          //         onPressed: () {},
          //       ),
          //     ),
          //     Expanded(
          //       child: TextButton(
          //         child: Text(
          //           'Ver publicaciones',
          //           style: TextStyle(fontSize: 10),
          //         ),
          //         onPressed: () {
          //           GoRouter.of(context)
          //               .goNamed(Routes.posts, params: {"id": userInfo.id});
          //         },
          //       ),
          //     )
          //   ],
          // ),
        ),
      ),
    );
  }
}

void _showActionSheet(
    BuildContext context, SearchUserDetails userInfo, WidgetRef ref) {
  showCupertinoModalPopup<void>(
    context: context,
    builder: (BuildContext context) => CupertinoActionSheet(
      title: const Text('Acciones sobre este usuario'),
      message: const Text('Test'),
      actions: <CupertinoActionSheetAction>[
        CupertinoActionSheetAction(
          onPressed: () {},
          child: const Text('Seguir usuario'),
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            GoRouter.of(context)
                .goNamed(Routes.posts, params: {"id": userInfo.id});
          },
          child: const Text('Ver publicaciones'),
        ),
        CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () {
            ref.watch(createPrivateConversationFutureProvider(userInfo.id));
            Navigator.of(context).pop();
            GoRouter.of(context).goNamed(Routes.conversations);
          },
          child: const Text('Crear una conversación'),
        ),
        CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () {},
          child: const Text('Cancelar'),
        ),
      ],
    ),
  );
}
