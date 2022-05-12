import 'package:skillsly_ma/src/core/constants/app.colors.dart';
import 'package:skillsly_ma/src/core/constants/palette.dart';
import 'package:skillsly_ma/src/core/localization/string_hardcoded.dart';
import 'package:skillsly_ma/src/core/routing/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);
    return MaterialApp.router(
      routerDelegate: goRouter.routerDelegate,
      routeInformationParser: goRouter.routeInformationParser,
      debugShowCheckedModeBanner: false,
      restorationScopeId: 'app',
      onGenerateTitle: (BuildContext context) => 'Skillsly'.hardcoded,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Palette.primary,
        ).copyWith(secondary: Palette.secondary, tertiary: Palette.tertiary),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.beige,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            primary: Palette.primary, // background (button) color
            onPrimary: AppColors.beige, // foreground (text) color
          ),
        ),
      ),
    );
  }
}
