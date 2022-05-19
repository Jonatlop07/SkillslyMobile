import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skillsly_ma/src/core/routing/routes.dart';
import 'package:skillsly_ma/src/features/chat/data/chat_service.dart';
import 'package:skillsly_ma/src/features/chat/domain/member.dart';

class ConversationWidget extends ConsumerStatefulWidget {
  String conversationID;
  String createdAt;
  bool isPrivate;
  List<Member> members;

  ConversationWidget({
    Key? key,
    required this.conversationID,
    required this.createdAt,
    required this.isPrivate,
    required this.members,
  }) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _ConversationState();
  }
}

class _ConversationState extends ConsumerState<ConversationWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => {
        GoRouter.of(context).goNamed(Routes.chat,
            params: {"userId": widget.members[0].user_id, "conversationId": widget.conversationID})
      },
      onLongPress: () => {_showActionSheet(context, widget, ref)},
      child: Container(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Row(
                children: <Widget>[
                  const CircleAvatar(
                    backgroundImage:
                        NetworkImage("https://cdn-icons-png.flaticon.com/512/3135/3135715.png"),
                    maxRadius: 30,
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.transparent,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            widget.conversationID,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          Text(widget.isPrivate ? "Conversacion privada" : "")
                          // Text(
                          //   widget.messageText,
                          //   style: TextStyle(
                          //       fontSize: 13,
                          //       color: Colors.grey.shade600,
                          //       fontWeight: widget.isMessageRead
                          //           ? FontWeight.bold
                          //           : FontWeight.normal),
                          // ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              widget.createdAt.split("-")[0] + "-" + widget.createdAt.split("-")[1],
              style: TextStyle(
                fontSize: 12,
                fontWeight: widget.isPrivate ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showActionSheet(BuildContext context, ConversationWidget widget, WidgetRef ref) {
  showCupertinoModalPopup<void>(
    context: context,
    builder: (BuildContext context) => CupertinoActionSheet(
      title: const Text('Acciones sobre esta conversacion'),
      message: Text('Tu conversación con : ' + widget.members[0].user_id),
      actions: <CupertinoActionSheetAction>[
        CupertinoActionSheetAction(
          /// This parameter indicates the action would perform
          /// a destructive action such as delete or exit and turns
          /// the action's text color to red.
          isDestructiveAction: true,
          onPressed: () {
            Navigator.pop(context);
            _showConfirmationDialog(context, widget, ref);
          },
          child: const Text('Borrar esta conversación'),
        )
      ],
    ),
  );
}

void _showConfirmationDialog(BuildContext context, ConversationWidget widget, WidgetRef ref) {
  showCupertinoDialog<ConsumerStatefulWidget>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
            title: const Text("Borrar conversación"),
            content: const Text("Esta seguro de eliminar esta conversación?"),
            actions: [
              CupertinoDialogAction(
                  isDestructiveAction: true,
                  child: const Text("Sí"),
                  onPressed: () {
                    ref.watch(deleteConversationFutureProvider(widget.conversationID));
                    Navigator.of(context).pop();
                    GoRouter.of(context).goNamed(Routes.feed);
                  }),
              CupertinoDialogAction(
                  child: const Text("No"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  })
            ],
          ));
}
