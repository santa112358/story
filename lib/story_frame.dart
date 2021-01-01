import 'package:flutter/material.dart';

class StoryFrame extends StatelessWidget {
  const StoryFrame({Key key, this.builder}) : super(key: key);
  final Widget Function(BuildContext context, int pageIndex, int stackIndex)
      builder;
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
