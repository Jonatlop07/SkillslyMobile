import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:skillsly_ma/src/shared/state/auth_token_provider.dart';

final graphQLClientProvider = Provider<ValueNotifier<GraphQLClient>>((ref) {
  final String token = ref.watch(authTokenProvider.state).state;
  final httpLink = HttpLink("http://855f-2800-e2-5980-2af7-bc9c-7465-cb53-6627.ngrok.io/graphql",
      defaultHeaders: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Credentials': 'true',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      });
  return ValueNotifier(GraphQLClient(link: httpLink, cache: GraphQLCache(store: HiveStore())));
});
