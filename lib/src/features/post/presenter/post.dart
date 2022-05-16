import 'package:flutter/cupertino.dart';
import 'package:skillsly_ma/src/core/common_widgets/responsive_center.dart';

class Post extends StatefulWidget {
  final String userId;

  Post({required this.userId}) {}
  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
  @override
  Widget build(BuildContext context) {
    return ResponsiveCenter(
        child: Row(
      children: [],
    ));
  }
}
