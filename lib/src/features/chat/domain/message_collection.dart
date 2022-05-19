import 'package:skillsly_ma/src/features/chat/domain/message.dart';


class MessageCollection {
  MessageCollection({required this.messageCollection});

  final List<Message> messageCollection;

  factory MessageCollection.getConversationsCollection(
      List<dynamic> response) {
    List<Message> messsages = [];
    response.forEach((element) {
      Message message = Message.fromJson(element);
      messsages.add(message);
    });
    return MessageCollection(messageCollection: messsages);
  }
}
