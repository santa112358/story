import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../story_stack_controller.dart';

class Indicators extends StatefulWidget {
  const Indicators({
    Key key,
    @required this.animationController,
    @required this.storyLength,
    @required this.isCurrentPage,
    @required this.isPaging,
    @required this.padding,
  }) : super(key: key);
  final int storyLength;
  final AnimationController animationController;
  final EdgeInsetsGeometry padding;
  final bool isCurrentPage;
  final bool isPaging;

  @override
  _IndicatorsState createState() => _IndicatorsState();
}

class _IndicatorsState extends State<Indicators> {
  Animation<double> indicatorAnimation;

  @override
  void initState() {
    super.initState();
    widget.animationController.forward();
    indicatorAnimation =
        Tween(begin: 0.0, end: 1.0).animate(widget.animationController)
          ..addListener(() {
            setState(() {});
          })
          ..addStatusListener(
            (status) {
              if (status == AnimationStatus.completed) {
                context.read<StoryStackController>().increment(
                    restartAnimation: () =>
                        widget.animationController.forward(from: 0));
              }
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    final currentStackIndex = context.watch<StoryStackController>().value;
    if (!widget.isCurrentPage && widget.isPaging) {
      widget.animationController.stop();
    }
    if (!widget.isCurrentPage &&
        !widget.isPaging &&
        widget.animationController.value != 0) {
      widget.animationController.value = 0;
    }
    if (widget.isCurrentPage && !widget.animationController.isAnimating) {
      widget.animationController.forward(from: 0);
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
            value: (index == currentStackIndex)
                ? indicatorAnimation.value
                : (index > currentStackIndex)
                    ? 0
                    : 1,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    widget.animationController.dispose();
  }
}

class _Indicator extends StatelessWidget {
  const _Indicator({
    Key key,
    @required this.index,
    @required this.value,
  }) : super(key: key);
  final int index;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(left: (index == 0) ? 0 : 4),
        child: LinearProgressIndicator(
          value: value,
          backgroundColor: Colors.black.withOpacity(0.08),
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          minHeight: 2,
        ),
      ),
    );
  }
}
