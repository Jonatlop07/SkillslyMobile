import 'package:flutter/material.dart';
import 'package:skillsly_ma/src/core/constants/app.sizes.dart';
import 'package:skillsly_ma/src/core/constants/breakpoints.dart';

import 'responsive_center.dart';

/// Scrollable widget that shows a responsive card with a given child widget.
/// Useful for displaying forms and other widgets that need to be scrollable.
class ResponsiveCard extends StatelessWidget {
  const ResponsiveCard({Key? key, required this.child}) : super(key: key);
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return ResponsiveCenter(
      maxContentWidth: Breakpoint.tablet,
      child: Padding(
        padding: const EdgeInsets.all(Sizes.p16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(Sizes.p16),
            child: child,
          ),
        ),
      ),
    );
  }
}
