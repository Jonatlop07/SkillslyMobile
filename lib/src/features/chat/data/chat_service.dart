import 'dart:ffi';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:skillsly_ma/src/core/config/graphql_config.dart';
import 'package:skillsly_ma/src/core/localization/string_hardcoded.dart';
import 'package:skillsly_ma/src/features/chat/domain/conversation.dart';
import 'package:skillsly_ma/src/features/chat/domain/conversation_collection.dart';
import 'package:skillsly_ma/src/features/chat/domain/message.dart';
import 'package:skillsly_ma/src/features/chat/domain/message_collection.dart';
import 'package:skillsly_ma/src/shared/exception/request_exception.dart';
import 'package:skillsly_ma/src/shared/state/app_user.dart';
import 'package:skillsly_ma/src/shared/state/auth_state_accessor.dart';

class ChatService {
  ChatService(this._client, Ref ref)
      : _authStateAccessor = AuthStateAccessor(ref);

  final GraphQLClient _client;
  final AuthStateAccessor _authStateAccessor;

  AppUser? get currentUser => _authStateAccessor.getAuthStateController().state;

  Future<void> deletePrivateConversation(String conversationID) async {
    final String userID = currentUser!.id;
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
    // print(result);
    if (result.hasException) {
      throw BackendRequestException(result.exception.toString());
    }
    if (result.isLoading && result.data != null) {
      throw BackendRequestException(
          'El servidor tardó mucho en responder. Por favor, inténtelo de nuevo'
              .hardcoded);
    }
  }

  Future<void> createPrivateConversation(String memberUserID) async {
    final String creatorUserID = currentUser!.id;
    final createPrivateConvesation = gql('''
      mutation createPrivateConversation(
        \$creator_user_id: String!,
        \$member_user_id: String!
      ) {
        createPrivateConversation(
          private_conversation: {
            creator_user_id: \$creator_user_id,
            member_user_id: \$member_user_id
          }
        ) 
      }
    ''');

    final result = await _client.mutate(
      MutationOptions(
        document: createPrivateConvesation,
        variables: {
          'creator_user_id': creatorUserID,
          'member_user_id': memberUserID
        },
      ),
    );
    // print(result);
    if (result.hasException) {
      throw BackendRequestException(result.exception.toString());
    }
    if (result.isLoading && result.data != null) {
      throw BackendRequestException(
          'El servidor tardó mucho en responder. Por favor, inténtelo de nuevo'
              .hardcoded);
    }
  }

  Future<void> createConversationMessage(
      String content, String conversationID) async {
    // print(content);
    // print(conversationID);
    final String ownerUserID = currentUser!.id;
    final createConversationMessage = gql('''
      mutation sendMessageToConversation(
        \$content: String!,
        \$conversation_id: String!
        \$owner_user_id: String!
      ) {
        sendMessageToConversation(
          message_to_conversation: {
            content: \$content,
            conversation_id: \$conversation_id
            owner_user_id: \$owner_user_id
          }
        ) 
      }
    ''');

    final result = await _client.mutate(
      MutationOptions(
        document: createConversationMessage,
        variables: {
          'content': content,
          'conversation_id': conversationID,
          'owner_user_id': ownerUserID
        },
      ),
    );
    // print(result);
    if (result.hasException) {
      throw BackendRequestException(result.exception.toString());
    }
    if (result.isLoading && result.data != null) {
      throw BackendRequestException(
          'El servidor tardó mucho en responder. Por favor, inténtelo de nuevo'
              .hardcoded);
    }
  }

  Stream<List<Conversation>> getConversationsCollection() async* {
    final String userID = currentUser!.id;
    // print(userID);
    final getConversationsCollection = gql('''
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
        document: getConversationsCollection,
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
    yield ConversationCollection.getConversationsCollection(
            result.data!['getConversationsCollection'] as List<dynamic>)
        .conversationCollection;
  }

  Stream<List<Message>> getConversationMessages(String conversationID) async* {
    final getConversationMessagesQuery = gql('''
  query getConversationMessages (
     \$conversationID: String!,
    ){
    getConversationMessages(get_messages :{
        conversation_id: \$conversationID
    }){
        content
        created_at
        owner_user_id
       }
    }
    ''');
    final result = await _client.mutate(
      MutationOptions(
        document: getConversationMessagesQuery,
        variables: {'conversationID': conversationID},
      ),
    );
    // print(result);
    if (result.hasException) {
      throw BackendRequestException(result.exception.toString());
    }
    if (result.isLoading && result.data != null) {
      throw BackendRequestException(
          'El servidor tardó mucho en responder. Por favor, inténtelo de nuevo'
              .hardcoded);
    }

    yield MessageCollection.getConversationsCollection(
            result.data!['getConversationMessages'] as List<dynamic>)
        .messageCollection;
  }

  bool isOwnerMessageUser(String ownerUserID) {
    final String userID = currentUser!.id;
    return userID == ownerUserID;
  }
}

final conversationsServiceProvider = Provider<ChatService>((ref) {
  final client = ref.watch(graphQLClientProvider).value;
  return ChatService(client, ref);
});

final conversationsListStreamProvider =
    StreamProvider.autoDispose<List<Conversation>>((ref) {
  final conversationsService = ref.watch(conversationsServiceProvider);
  return conversationsService.getConversationsCollection();
});

final conversationMessagesStreamProvider = StreamProvider.autoDispose
    .family<List<Message>, String>((ref, conversationID) {
  final conversationsService = ref.watch(conversationsServiceProvider);
  return conversationsService.getConversationMessages(conversationID);
});

final deleteConversationFutureProvider =
    FutureProvider.autoDispose.family<void, String>((ref, conversationID) {
  final conversationsService = ref.watch(conversationsServiceProvider);
  conversationsService.deletePrivateConversation(
    conversationID,
  );
});

final createPrivateConversationFutureProvider =
    FutureProvider.autoDispose.family<void, String>((ref, memberUserID) {
  final conversationsService = ref.watch(conversationsServiceProvider);
  conversationsService.createPrivateConversation(memberUserID);
});

final createConversationMessageFutureProvider =
    FutureProvider.autoDispose.family<void, dynamic>((ref, messageInfo) {
  final conversationsService = ref.watch(conversationsServiceProvider);
  conversationsService.createConversationMessage(
      messageInfo['content'], messageInfo['conversationID']);
});

final isOwnerMessageUserProvider =
    ProviderFamily<bool, String>((ref, ownerUserID) {
  final conversationsService = ref.watch(conversationsServiceProvider);
  return conversationsService.isOwnerMessageUser(ownerUserID);
});
