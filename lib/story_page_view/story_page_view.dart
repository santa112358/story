import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:story/story_page_view/story_stack_controller.dart';

import 'components/gestures.dart';
import 'components/indicators.dart';

typedef _StoryItemBuilder = Widget Function(
    BuildContext context, int pageIndex, int storyIndex);

typedef _StoryConfigFunction = int Function(int pageIndex);

/// PageView to implement story like UI
///
/// [itemBuilder], [storyLength], [pageLength] are required.
class StoryPageView extends StatefulWidget {
  StoryPageView({
    Key key,
    @required this.itemBuilder,
    @required this.storyLength,
    @required this.pageLength,
    this.initialStoryIndex,
    this.initialPage = 0,
    this.onPageLimitReached,
    this.indicatorDuration = const Duration(seconds: 5),
    this.indicatorPadding =
        const EdgeInsets.symmetric(vertical: 32, horizontal: 8),
    this.backgroundColor = Colors.black,
  })  : assert(pageLength != null),
        assert(storyLength != null),
        assert(itemBuilder != null),
        super(key: key);

  /// Function to build story content
  final _StoryItemBuilder itemBuilder;

  /// decides length of story for each page
  final _StoryConfigFunction storyLength;

  /// length of [StoryPageView]
  final int pageLength;

  /// Initial index of story for each page
  final _StoryConfigFunction initialStoryIndex;

  /// padding of [Indicators]
  final EdgeInsetsGeometry indicatorPadding;

  /// duration of [Indicators]
  final Duration indicatorDuration;

  /// Called when the very last story is finished.
  ///
  /// Functions like "Navigator.pop(context)" is expected.
  final VoidCallback onPageLimitReached;

  /// initial index for [StoryPageView]
  final int initialPage;

  final Color backgroundColor;

  @override
  _StoryPageViewState createState() => _StoryPageViewState();
}

class _StoryPageViewState extends State<StoryPageView> {
  PageController pageController;

  var currentPageValue = 0.0;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: widget.initialPage);
      
    if(widget.initialPage != null) {
      currentPageValue = widget.initialPage.toDouble();
    }
      
    pageController.addListener(() {
      setState(() {
        currentPageValue = pageController.page;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: widget.backgroundColor,
      child: PageView.builder(
        controller: pageController,
        itemCount: widget.pageLength,
        itemBuilder: (context, index) {
          final isLeaving = (index - currentPageValue) <= 0;
          final t = (index - currentPageValue);
          final rotationY = lerpDouble(0, 30, t);
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
                _StoryPageFrame.wrapped(
                  pageLength: widget.pageLength,
                  storyLength: widget.storyLength(index),
                  initialStoryIndex: widget.initialStoryIndex?.call(index) ?? 0,
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

class _StoryPageFrame extends StatefulWidget {
  const _StoryPageFrame._({
    Key key,
    @required this.storyLength,
    @required this.initialStoryIndex,
    @required this.pageIndex,
    @required this.isCurrentPage,
    @required this.isPaging,
    @required this.itemBuilder,
    @required this.indicatorDuration,
    @required this.indicatorPadding,
  }) : super(key: key);
  final int storyLength;
  final int initialStoryIndex;
  final int pageIndex;
  final bool isCurrentPage;
  final bool isPaging;
  final _StoryItemBuilder itemBuilder;
  final Duration indicatorDuration;
  final EdgeInsetsGeometry indicatorPadding;

  static Widget wrapped({
    @required int pageIndex,
    @required int pageLength,
    @required ValueChanged<int> animateToPage,
    @required int storyLength,
    @required int initialStoryIndex,
    @required bool isCurrentPage,
    @required bool isPaging,
    @required VoidCallback onPageLimitReached,
    @required _StoryItemBuilder itemBuilder,
    @required Duration indicatorDuration,
    @required EdgeInsetsGeometry indicatorPadding,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_context) => StoryStackController(
            storyLength: storyLength,
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
      child: _StoryPageFrame._(
        storyLength: storyLength,
        initialStoryIndex: initialStoryIndex,
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

class _StoryPageFrameState extends State<_StoryPageFrame>
    with
        AutomaticKeepAliveClientMixin<_StoryPageFrame>,
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
          storyLength: widget.storyLength,
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
