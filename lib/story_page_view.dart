import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:story/story_stack_controller.dart';

typedef StoryItemBuilder = Widget Function(
    BuildContext context, int pageIndex, int stackIndex);

class StoryPageView extends StatefulWidget {
  StoryPageView({
    Key key,
    @required this.itemBuilder,
    @required this.stackLength,
    @required this.pageLength,
    this.initialPage = 0,
    this.onPageLimitReached,
    this.indicatorDuration = const Duration(seconds: 5),
    this.indicatorPadding =
        const EdgeInsets.symmetric(vertical: 32, horizontal: 8),
  })  : assert(pageLength != null),
        assert(stackLength != null),
        assert(itemBuilder != null),
        super(key: key);

  final StoryItemBuilder itemBuilder;
  final int Function(int pageIndex) stackLength;
  final int pageLength;

  final EdgeInsetsGeometry indicatorPadding;
  final Duration indicatorDuration;
  final VoidCallback onPageLimitReached;
  final int initialPage;

  @override
  _StoryPageViewState createState() => _StoryPageViewState();
}

class _StoryPageViewState extends State<StoryPageView> {
  PageController pageController;

  var currentPageValue = 0.0;
  var currentPageIndex;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: widget.initialPage);
    pageController.addListener(() {
      setState(() {
        currentPageValue = pageController.page;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: pageController,
        itemCount: widget.pageLength,
        itemBuilder: (context, index) {
          final isLeaving = (index - currentPageValue) <= 0;
          final t = (index - currentPageValue);
          final rotationY = lerpDouble(0, 15, t);
          final maxOpacity = 0.8;
          final opacity =
              lerpDouble(0, maxOpacity, t.abs()).clamp(0.0, maxOpacity);
          final isPaging = opacity != maxOpacity;
          final transform = Matrix4.identity();
          transform.setEntry(3, 2, 0.003);
          transform.rotateY(-rotationY * (pi / 180.0));
          return Transform(
            alignment: isLeaving ? Alignment.centerRight : Alignment.centerLeft,
            transform: transform,
            child: Stack(
              children: [
                StoryPageFrame.wrapped(
                  pageLength: widget.pageLength,
                  stackLength: widget.stackLength(index),
                  pageIndex: index,
                  animateToPage: (index) {
                    pageController.animateToPage(index,
                        duration: Duration(milliseconds: 500),
                        curve: Curves.ease);
                  },
                  isCurrentPage: currentPageValue == index,
                  isPaging: isPaging,
                  onPageLimitReached: widget.onPageLimitReached,
                  itemBuilder: widget.itemBuilder,
                  indicatorDuration: widget.indicatorDuration,
                  indicatorPadding: widget.indicatorPadding,
                ),
                if (isPaging && !isLeaving)
                  Positioned.fill(
                    child: Opacity(
                      opacity: opacity,
                      child: ColoredBox(
                        color: Colors.black87,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class StoryPageFrame extends StatefulWidget {
  const StoryPageFrame._({
    Key key,
    @required this.stackLength,
    @required this.pageIndex,
    @required this.isCurrentPage,
    @required this.isPaging,
    @required this.itemBuilder,
    @required this.indicatorDuration,
    @required this.indicatorPadding,
  }) : super(key: key);
  final int stackLength;
  final int pageIndex;
  final bool isCurrentPage;
  final bool isPaging;
  final StoryItemBuilder itemBuilder;
  final Duration indicatorDuration;
  final EdgeInsetsGeometry indicatorPadding;

  static Widget wrapped({
    @required int pageIndex,
    @required int pageLength,
    @required ValueChanged<int> animateToPage,
    @required int stackLength,
    @required bool isCurrentPage,
    @required bool isPaging,
    @required VoidCallback onPageLimitReached,
    @required StoryItemBuilder itemBuilder,
    @required Duration indicatorDuration,
    @required EdgeInsetsGeometry indicatorPadding,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_context) => StoryStackController(
            stackLength: stackLength,
            onPageBack: () {
              if (pageIndex != 0) {
                animateToPage(pageIndex - 1);
              }
            },
            onPageForward: () {
              if (pageIndex == pageLength - 1) {
                onPageLimitReached?.call();
              } else {
                animateToPage(pageIndex + 1);
              }
            },
          ),
        ),
      ],
      child: StoryPageFrame._(
        stackLength: stackLength,
        pageIndex: pageIndex,
        isCurrentPage: isCurrentPage,
        isPaging: isPaging,
        itemBuilder: itemBuilder,
        indicatorDuration: indicatorDuration,
        indicatorPadding: indicatorPadding,
      ),
    );
  }

  @override
  _StoryPageFrameState createState() => _StoryPageFrameState();
}

class _StoryPageFrameState extends State<StoryPageFrame>
    with
        AutomaticKeepAliveClientMixin<StoryPageFrame>,
        SingleTickerProviderStateMixin {
  AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: widget.indicatorDuration ?? Duration(seconds: 5),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      fit: StackFit.loose,
      alignment: Alignment.topLeft,
      children: [
        Positioned.fill(
          child: ColoredBox(
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
        ),
        Positioned.fill(
          child: widget.itemBuilder(
            context,
            widget.pageIndex,
            context.watch<StoryStackController>().value,
          ),
        ),
        Container(
          height: 50,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 10,
                blurRadius: 20,
              ),
            ],
          ),
        ),
        Indicators(
          stackLength: widget.stackLength,
          animationController: animationController,
          isCurrentPage: widget.isCurrentPage,
          isPaging: widget.isPaging,
          padding: widget.indicatorPadding,
        ),
        Gestures(
          animationController: animationController,
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class Gestures extends StatelessWidget {
  const Gestures({
    Key key,
    @required this.animationController,
  }) : super(key: key);

  final AnimationController animationController;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: () {
                animationController.forward(from: 0);
                context.read<StoryStackController>().decrement();
              },
              onLongPress: () {
                animationController.stop();
              },
              onLongPressUp: () {
                animationController.forward();
              },
            ),
          ),
        ),
        Expanded(
          child: Container(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: () {
                context.read<StoryStackController>().increment(
                      restartAnimation: () =>
                          animationController.forward(from: 0),
                      completeAnimation: () => animationController.value = 1,
                    );
              },
              onLongPress: () {
                animationController.stop();
              },
              onLongPressUp: () {
                animationController.forward();
              },
            ),
          ),
        ),
      ],
    );
  }
}

class Indicators extends StatefulWidget {
  const Indicators({
    Key key,
    @required this.animationController,
    @required this.stackLength,
    @required this.isCurrentPage,
    @required this.isPaging,
    @required this.padding,
  }) : super(key: key);
  final int stackLength;
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
          widget.stackLength,
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
