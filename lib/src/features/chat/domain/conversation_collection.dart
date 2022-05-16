import 'conversation.dart';

class ConversationCollection {
  ConversationCollection({required this.conversationCollection});

  final List<Conversation> conversationCollection;

  factory ConversationCollection.getConversationsCollection(
      List<dynamic> response) {
    List<Conversation> conversations = [];
    response.forEach((element) {
      Conversation conversation = Conversation.fromJson(element);
      conversations.add(conversation);
    });
    return ConversationCollection(conversationCollection: conversations);
  }
}
