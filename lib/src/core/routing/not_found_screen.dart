import 'package:flutter/material.dart';
import 'package:skillsly_ma/src/core/common_widgets/empty_placeholder_widget.dart';
import 'package:skillsly_ma/src/core/localization/string_hardcoded.dart';

/// Simple not found screen used for 404 errors (page not found on web)
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: EmptyPlaceholderWidget(
        message: '404 - Página no encontrada'.hardcoded,
      ),
    );
  }
}
