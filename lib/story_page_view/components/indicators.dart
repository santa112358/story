import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:story/story_page_view/story_limit_controller.dart';

import '../story_stack_controller.dart';

class Indicators extends StatefulWidget {
  const Indicators({
    Key? key,
    required this.animationController,
    required this.storyLength,
    required this.isCurrentPage,
    required this.isPaging,
    required this.padding,
    required this.indicatorUnvisitedColor,
    required this.indicatorVisitedColor,
  }) : super(key: key);
  final int storyLength;
  final AnimationController? animationController;
  final EdgeInsetsGeometry padding;
  final bool isCurrentPage;
  final bool isPaging;
  final Color indicatorVisitedColor;
  final Color indicatorUnvisitedColor;

  @override
  _IndicatorsState createState() => _IndicatorsState();
}

class _IndicatorsState extends State<Indicators> {
  late Animation<double> indicatorAnimation;

  @override
  void initState() {
    super.initState();
    widget.animationController!.forward();
    indicatorAnimation =
        Tween(begin: 0.0, end: 1.0).animate(widget.animationController!)
          ..addListener(() {
            setState(() {});
          });
  }

  @override
  Widget build(BuildContext context) {
    final int currentStoryIndex = context.watch<StoryStackController>().value;
    final bool isStoryEnded = context.watch<StoryLimitController>().value;
    if (!widget.isCurrentPage && widget.isPaging) {
      widget.animationController!.stop();
    }
    if (!widget.isCurrentPage &&
        !widget.isPaging &&
        widget.animationController!.value != 0) {
      widget.animationController!.value = 0;
    }
    if (widget.isCurrentPage &&
        !widget.animationController!.isAnimating &&
        !isStoryEnded) {
      widget.animationController!.forward(from: 0);
    }
    return Padding(
      padding: widget.padding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
          widget.storyLength,
          (index) => _Indicator(
            index: index,
            value: (index == currentStoryIndex)
                ? indicatorAnimation.value
                : (index > currentStoryIndex)
                    ? 0
                    : 1,
            indicatorVisitedColor: widget.indicatorVisitedColor,
            indicatorUnvisitedColor: widget.indicatorUnvisitedColor,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    widget.animationController!.dispose();
  }
}

class _Indicator extends StatelessWidget {
  const _Indicator({
    Key? key,
    required this.index,
    required this.value,
    required this.indicatorVisitedColor,
    required this.indicatorUnvisitedColor,
  }) : super(key: key);
  final int index;
  final double value;
  final Color indicatorVisitedColor;
  final Color indicatorUnvisitedColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(left: (index == 0) ? 0 : 4),
        child: LinearProgressIndicator(
          value: value,
          backgroundColor: indicatorUnvisitedColor,
          valueColor: AlwaysStoppedAnimation<Color>(indicatorVisitedColor),
          minHeight: 2,
        ),
      ),
    );
  }
}
