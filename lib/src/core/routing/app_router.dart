import 'package:skillsly_ma/src/core/routing/route_paths.dart';
import 'package:skillsly_ma/src/core/routing/transition_screen.dart';
import 'package:skillsly_ma/src/features/account_settings/presentation/account_credentials/account_credentials_screen.dart';
import 'package:skillsly_ma/src/features/account_settings/presentation/account_credentials/account_credentials_state.dart';
import 'package:skillsly_ma/src/features/account_settings/presentation/account_details/account_details_screen.dart';
import 'package:skillsly_ma/src/features/account_settings/presentation/account_details/account_details_state.dart';
import 'package:skillsly_ma/src/features/authentication/data/auth_service.dart';
import 'package:skillsly_ma/src/features/authentication/presentation/sign_in/sign_in_screen.dart';
import 'package:skillsly_ma/src/features/authentication/presentation/sign_in/sign_in_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skillsly_ma/src/features/authentication/presentation/sign_up/sign_up_screen.dart';
import 'package:skillsly_ma/src/features/authentication/presentation/sign_up/sign_up_state.dart';
import 'package:skillsly_ma/src/features/comments/domain/comment_details.dart';
import 'package:skillsly_ma/src/features/comments/presentation/comments/comments_list.dart';
import 'package:skillsly_ma/src/features/comments/presentation/comments/edit_comment/edit_comment_screen.dart';
import 'package:skillsly_ma/src/features/chat/presentation/conversation/chat.screen.dart';
import 'package:skillsly_ma/src/features/post/presenter/create_post/create_post_screen.dart';
import 'package:skillsly_ma/src/features/post/presenter/feed/feed_screen.dart';
import 'package:skillsly_ma/src/features/post/presenter/posts_of_user/posts_of_user_screen.dart';
import 'package:skillsly_ma/src/features/users/presentation/search/search_users_screen.dart';

import '../../features/chat/presentation/user_conversations/user_conversations.screen.dart';
import 'not_found_screen.dart';
import 'routes.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authService = ref.watch(authServiceProvider);
  return GoRouter(
    initialLocation: RoutePaths.home,
    debugLogDiagnostics: false,
    redirect: (state) {
      final isLoggedIn = authService.isLoggedIn();
      final isLoggingIn = state.subloc == RoutePaths.signIn ||
          state.subloc == RoutePaths.signUp;
      if (!isLoggedIn) return isLoggingIn ? null : RoutePaths.signIn;
      if (isLoggingIn || isLoggedIn && state.subloc == RoutePaths.home)
        return RoutePaths.feed;
      return null;
    },
    refreshListenable: GoRouterRefreshStream(authService.authStateChanges()),
    routes: [
      GoRoute(
        path: RoutePaths.home,
        name: Routes.home,
        builder: (context, state) => const NotFoundScreen(),
        routes: [
          GoRoute(
            path: Routes.signIn,
            name: Routes.signIn,
            pageBuilder: (context, state) => TransitionScreen.createFade(
              context,
              state,
              const SignInScreen(
                formType: SignInFormType.signIn,
              ),
            ),
          ),
          GoRoute(
            path: Routes.signUp,
            name: Routes.signUp,
            pageBuilder: (context, state) => TransitionScreen.createFade(
                context,
                state,
                const SignUpScreen(
                  formType: SignUpFormType.signUp,
                )),
          ),
          GoRoute(
            path: Routes.feed,
            name: Routes.feed,
            pageBuilder: (context, state) => TransitionScreen.createFade(
              context,
              state,
              const FeedScreen(),
            ),
            routes: [
              GoRoute(
                path: Routes.createPost,
                name: Routes.createPost,
                pageBuilder: (context, state) => TransitionScreen.createFade(
                  context,
                  state,
                  const CreatePostScreen(),
                ),
              ),
              GoRoute(
                path: '${Routes.postsOfUser}/:ownerId',
                name: Routes.postsOfUser,
                pageBuilder: (context, state) => TransitionScreen.createFade(
                  context,
                  state,
                  PostsOfUserScreen(ownerId: state.params['ownerId']!),
                ),
              ),
            ],
          ),
          GoRoute(
            path: Routes.conversations,
            name: Routes.conversations,
            pageBuilder: (context, state) => TransitionScreen.createFade(
                context, state, const UserConversationsScreen()),
          ),
          GoRoute(
            path: '${Routes.chat}/:userId/:conversationId',
            name: Routes.chat,
            pageBuilder: (context, state) => TransitionScreen.createFade(
              context,
              state,
              ChatScreen(
                userId: state.params['userId'] ?? '',
                conversationId: state.params['conversationId'] ?? '',
              ),
            ),
          ),
          GoRoute(
            path: Routes.account,
            name: Routes.account,
            pageBuilder: (context, state) => TransitionScreen.createFade(
              context,
              state,
              const AccountDetailsScreen(
                formType: AccountDetailsFormType.accountDetails,
              ),
            ),
            routes: [
              GoRoute(
                path: Routes.credentials,
                name: Routes.credentials,
                pageBuilder: (context, state) => TransitionScreen.createFade(
                  context,
                  state,
                  const AccountCredentialsScreen(
                    formType: AccountCredentialsFormType.updateCredentials,
                  ),
                ),
              ),
            ],
          ),
          GoRoute(
            path: '${Routes.comments}/:postId',
            name: Routes.comments,
            pageBuilder: (context, state) => TransitionScreen.createFade(
              context,
              state,
              CommentsList(
                postId: state.params['postId']!,
              ),
            ),
          ),
          GoRoute(
              path: Routes.editComment,
              name: Routes.editComment,
              pageBuilder: (context, state) => TransitionScreen.createFade(
                  context,
                  state,
                  EditCommentScreen(
                    comment_details: state.extra! as CommentDetails,
                  ))),
          GoRoute(
              path: Routes.searchUser,
              name: Routes.searchUser,
              pageBuilder: (context, state) => TransitionScreen.createFade(
                    context,
                    state,
                    const SearchUserScreen(),
                  )),
        ],
      ),
    ],
    errorBuilder: (context, state) => const NotFoundScreen(),
  );
});
