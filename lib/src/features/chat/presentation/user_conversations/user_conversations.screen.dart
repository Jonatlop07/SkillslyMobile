import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skillsly_ma/src/core/common_widgets/async_value_widget.dart';
import 'package:skillsly_ma/src/core/localization/string_hardcoded.dart';
import 'package:skillsly_ma/src/core/routing/routes.dart';
import 'package:skillsly_ma/src/features/chat/data/chat_service.dart';
import 'package:skillsly_ma/src/features/chat/domain/conversation.dart';
import 'package:skillsly_ma/src/features/chat/presentation/conversation/conversation.screen.dart';

class UserConversationsScreen extends ConsumerWidget {
  const UserConversationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsList = ref.watch(conversationsListStreamProvider);

    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      "Mis conversaciones".hardcoded,
                      style: const TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 8, right: 8, top: 2, bottom: 2),
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Theme.of(context).colorScheme.secondary.withOpacity(0.05),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          GoRouter.of(context).goNamed(Routes.searchUser);
                        },
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.add,
                              color: Theme.of(context).colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(
                              width: 2,
                            ),
                            Text(
                              "Crear".hardcoded,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 20, left: 20, right: 20),
              //   child: TextField(
              //     enabled: false,
              //     decoration: InputDecoration(
              //       hintText: "Busca un usuario".hardcoded,
              //       hintStyle: TextStyle(color: Colors.grey.shade600),
              //       prefixIcon: Icon(
              //         Icons.search,
              //         color: Colors.grey.shade600,
              //         size: 20,
              //       ),
              //       filled: true,
              //       fillColor: Colors.grey.shade100,
              //       contentPadding: const EdgeInsets.all(8),
              //       enabledBorder: OutlineInputBorder(
              //           borderRadius: BorderRadius.circular(20),
              //           borderSide: BorderSide(color: Colors.grey.shade100)),
              //     ),
              //   ),
            ),
            AsyncValueWidget<List<Conversation>>(
              value: conversationsList,
              data: (conversation) => conversation.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 30),
                        child: Text(
                          'No se encontraron conversaciones'.hardcoded,
                          style: TextStyle(
                              color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: conversation.length,
                      shrinkWrap: true,
                      padding: const EdgeInsets.only(top: 16),
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return ConversationWidget(
                          conversationID: conversation[index].id,
                          createdAt: conversation[index].createdAt,
                          isPrivate: conversation[index].isPrivate,
                          members: conversation[index].members,
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }
}
