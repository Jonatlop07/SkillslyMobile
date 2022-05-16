import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skillsly_ma/src/core/common_widgets/responsive_scrollable_card.dart';
import 'package:skillsly_ma/src/core/constants/app.sizes.dart';
import 'package:skillsly_ma/src/core/constants/palette.dart';
import 'package:skillsly_ma/src/core/localization/string_hardcoded.dart';
import 'package:skillsly_ma/src/core/routing/routes.dart';
import 'package:skillsly_ma/src/features/authentication/data/auth_service.dart';

class MainDrawer extends ConsumerWidget {
  const MainDrawer({Key? key}) : super(key: key);

  Widget buildListTile(
      String title, IconData icon, void Function()? tapHandler) {
    return ListTile(
      leading: Icon(
        icon,
        size: Sizes.p32,
        color: Palette.primary,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: Sizes.p16,
          fontWeight: FontWeight.w400,
        ),
      ),
      onTap: tapHandler,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      backgroundColor: Palette.primary,
      child: ResponsiveScrollableCard(
        child: Column(
          children: <Widget>[
            Text(
              'Skillsly'.hardcoded,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: Sizes.p32,
                color: Palette.primary,
              ),
            ),
            gapH20,
            buildListTile('Feed', Icons.feed, () {
              GoRouter.of(context).goNamed(Routes.feed);
            }),
            buildListTile('Chat', Icons.add_comment_rounded, () {
              GoRouter.of(context).goNamed(Routes.chat);
            }),
            buildListTile('Mi Cuenta', Icons.account_circle_rounded, () {
              GoRouter.of(context).goNamed(Routes.account);
            }),
            buildListTile('Cerrar sesión', Icons.logout, () {
              final AuthService authService = ref.read(authServiceProvider);
              authService.logOut();
            }),
          ],
        ),
      ),
    );
  }
}
