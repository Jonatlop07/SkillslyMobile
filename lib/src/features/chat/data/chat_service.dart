import 'dart:ffi';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:skillsly_ma/src/core/config/graphql_config.dart';
import 'package:skillsly_ma/src/core/localization/string_hardcoded.dart';
import 'package:skillsly_ma/src/features/chat/domain/conversation.dart';
import 'package:skillsly_ma/src/features/chat/domain/conversation_collection.dart';
import 'package:skillsly_ma/src/shared/exception/request_exception.dart';

class ChatService {
  ChatService(this._client);

  final GraphQLClient _client;

  Future<void> deletePrivateConversation(String conversationID,
      String userID) async {

    final deleteConversation = gql('''
      mutation deleteConversation(
        \$conversation_id: String!,
        \$user_id: String!
      ) {
        deleteConversation(
          delete_conversation: {
            conversation_id: \$conversation_id,
            user_id: \$user_id
          }
        ) 
      }
    ''');

    final result = await _client.mutate(
      MutationOptions(
        document: deleteConversation,
        variables: {'conversation_id': conversationID, 'user_id': userID},
      ),
    );
    print(result);
    if (result.hasException) {
      throw BackendRequestException(result.exception.toString());
    }
    if (result.isLoading && result.data != null) {
      throw BackendRequestException(
          'El servidor tardó mucho en responder. Por favor, inténtelo de nuevo'
              .hardcoded);
    }
  }

  Stream<List<Conversation>> getConversationsCollection(String userID) async* {
    print(userID);
    final signInUser = gql('''
    query getConversationsCollection (
     \$userID: String!,
    ){
    getConversationsCollection(get_conversations_collection :{
        user_id: \$userID
    }){
        conversation_id
        creator_user_id
        is_private
        created_at
        members{
            user_id
        }
       }
    }
    ''');

    final result = await _client.mutate(
      MutationOptions(
        document: signInUser,
        variables: {'userID': userID},
      ),
    );

    if (result.hasException) {
      throw BackendRequestException(result.exception.toString());
    }
    if (result.isLoading && result.data != null) {
      throw BackendRequestException(
          'El servidor tardó mucho en responder. Por favor, inténtelo de nuevo'
              .hardcoded);
    }
    // print(result.data);
    yield ConversationCollection
        .getConversationsCollection(
        result.data!['getConversationsCollection'] as List<dynamic>)
        .conversationCollection;
  }
}

final conversationsServiceProvider = Provider<ChatService>((ref) {
  final client = ref
      .watch(graphQLClientProvider)
      .value;
  return ChatService(client);
});

final conversationsListStreamProvider =
StreamProvider.autoDispose<List<Conversation>>((ref) {
  final conversationsService = ref.watch(conversationsServiceProvider);
  return conversationsService
      .getConversationsCollection("74e0b4f0-bf2d-430c-9ff0-34f00f40e0af");
});

final deleteConversationFutureProvider =
FutureProvider.autoDispose.family<void, String>((ref, conversationID) {
  final conversationsService = ref.watch(conversationsServiceProvider);
  conversationsService.deletePrivateConversation(
      conversationID, "74e0b4f0-bf2d-430c-9ff0-34f00f40e0af");
});
