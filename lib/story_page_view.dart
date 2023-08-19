import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:story/story_image.dart';

typedef _StoryItemBuilder = Widget Function(
  BuildContext context,
  int pageIndex,
  int storyIndex,
);

typedef _StoryConfigFunction = int Function(int pageIndex);

enum IndicatorAnimationCommand { pause, resume }

/// PageView to implement story like UI
///
/// [itemBuilder], [storyLength], [pageLength] are required.
class StoryPageView extends StatefulWidget {
  StoryPageView({
    Key? key,
    required this.itemBuilder,
    required this.storyLength,
    required this.pageLength,
    this.gestureItemBuilder,
    this.initialStoryIndex,
    this.initialPage = 0,
    this.onPageLimitReached,
    this.indicatorDuration = const Duration(seconds: 5),
    this.indicatorPadding =
        const EdgeInsets.symmetric(vertical: 32, horizontal: 8),
    this.backgroundColor = Colors.black,
    this.indicatorAnimationController,
    this.onPageChanged,
    this.indicatorVisitedColor = Colors.white,
    this.indicatorUnvisitedColor = Colors.grey,
    this.indicatorHeight = 2,
    this.showShadow = false,
  }) : super(key: key);

  ///  visited color of [_Indicators]
  final Color indicatorVisitedColor;

  ///  unvisited color of [_Indicators]
  final Color indicatorUnvisitedColor;

  /// Function to build story content
  final _StoryItemBuilder itemBuilder;

  /// Function to build story content
  /// Components with gesture actions are expected
  /// Placed above the story gestures.
  final _StoryItemBuilder? gestureItemBuilder;

  /// decides length of story for each page
  final _StoryConfigFunction storyLength;

  /// length of [StoryPageView]
  final int pageLength;

  /// Initial index of story for each page
  final _StoryConfigFunction? initialStoryIndex;

  /// padding of [_Indicators]
  final EdgeInsetsGeometry indicatorPadding;

  /// duration of [_Indicators]
  final Duration indicatorDuration;

  /// Called when the very last story is finished.
  ///
  /// Functions like "Navigator.pop(context)" is expected.
  final VoidCallback? onPageLimitReached;

  /// Called whenever the page in the center of the viewport changes.
  final void Function(int)? onPageChanged;

  /// initial index for [StoryPageView]
  final int initialPage;

  /// Color under the Stories which is visible when the cube transition is in progress
  final Color backgroundColor;

  /// Width of indicator
  final double indicatorHeight;

  /// Whether to show shadow near indicator
  final bool showShadow;

  /// A stream with [IndicatorAnimationCommand] to force pause or continue inticator animation
  /// Useful when you need to show any popup over the story
  final ValueNotifier<IndicatorAnimationCommand>? indicatorAnimationController;

  @override
  _StoryPageViewState createState() => _StoryPageViewState();
}

class _StoryPageViewState extends State<StoryPageView> {
  PageController? pageController;

  var currentPageValue;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: widget.initialPage);

    currentPageValue = widget.initialPage.toDouble();

    pageController!.addListener(() {
      setState(() {
        currentPageValue = pageController!.page;
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
        onPageChanged: widget.onPageChanged,
        itemBuilder: (context, index) {
          final isLeaving = (index - currentPageValue) <= 0;
          final t = (index - currentPageValue);
          final rotationY = lerpDouble(0, 30, t as double)!;
          final maxOpacity = 0.8;
          final num opacity =
              lerpDouble(0, maxOpacity, t.abs())!.clamp(0.0, maxOpacity);
          final isPaging = opacity != maxOpacity;
          final transform = Matrix4.identity();
          transform.setEntry(3, 2, 0.003);
          transform.rotateY(-rotationY * (pi / 180.0));
          return Transform(
            alignment: isLeaving ? Alignment.centerRight : Alignment.centerLeft,
            transform: transform,
            child: Stack(
              children: [
                _StoryPageBuilder.wrapped(
                  showShadow: widget.showShadow,
                  indicatorHeight: widget.indicatorHeight,
                  pageLength: widget.pageLength,
                  storyLength: widget.storyLength(index),
                  initialStoryIndex: widget.initialStoryIndex?.call(index) ?? 0,
                  pageIndex: index,
                  animateToPage: (index) {
                    pageController!.animateToPage(index,
                        duration: Duration(milliseconds: 500),
                        curve: Curves.ease);
                  },
                  isCurrentPage: currentPageValue == index,
                  isPaging: isPaging,
                  onPageLimitReached: widget.onPageLimitReached,
                  itemBuilder: widget.itemBuilder,
                  gestureItemBuilder: widget.gestureItemBuilder,
                  indicatorDuration: widget.indicatorDuration,
                  indicatorPadding: widget.indicatorPadding,
                  indicatorAnimationController:
                      widget.indicatorAnimationController,
                  indicatorUnvisitedColor: widget.indicatorUnvisitedColor,
                  indicatorVisitedColor: widget.indicatorVisitedColor,
                ),
                if (isPaging && !isLeaving)
                  Positioned.fill(
                    child: Opacity(
                      opacity: opacity as double,
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

class _StoryPageBuilder extends StatefulWidget {
  const _StoryPageBuilder._({
    Key? key,
    required this.storyLength,
    required this.initialStoryIndex,
    required this.pageIndex,
    required this.isCurrentPage,
    required this.isPaging,
    required this.itemBuilder,
    required this.gestureItemBuilder,
    required this.indicatorDuration,
    required this.indicatorPadding,
    required this.indicatorAnimationController,
    required this.indicatorUnvisitedColor,
    required this.indicatorVisitedColor,
    required this.indicatorHeight,
    required this.showShadow,
  }) : super(key: key);
  final int storyLength;
  final int initialStoryIndex;
  final int pageIndex;
  final bool isCurrentPage;
  final bool isPaging;
  final _StoryItemBuilder itemBuilder;
  final _StoryItemBuilder? gestureItemBuilder;
  final Duration indicatorDuration;
  final EdgeInsetsGeometry indicatorPadding;
  final ValueNotifier<IndicatorAnimationCommand>? indicatorAnimationController;
  final Color indicatorVisitedColor;
  final Color indicatorUnvisitedColor;
  final double indicatorHeight;
  final bool showShadow;

  static Widget wrapped({
    required int pageIndex,
    required int pageLength,
    required ValueChanged<int> animateToPage,
    required int storyLength,
    required int initialStoryIndex,
    required bool isCurrentPage,
    required bool isPaging,
    required VoidCallback? onPageLimitReached,
    required _StoryItemBuilder itemBuilder,
    _StoryItemBuilder? gestureItemBuilder,
    required Duration indicatorDuration,
    required EdgeInsetsGeometry indicatorPadding,
    required ValueNotifier<IndicatorAnimationCommand>?
        indicatorAnimationController,
    required Color indicatorVisitedColor,
    required Color indicatorUnvisitedColor,
    required double indicatorHeight,
    required bool showShadow,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_context) => _StoryLimitController(),
        ),
        ChangeNotifierProvider(
          create: (_context) => _StoryStackController(
            storyLength: storyLength,
            onPageBack: () {
              if (pageIndex != 0) {
                animateToPage(pageIndex - 1);
              }
            },
            onPageForward: () {
              if (pageIndex == pageLength - 1) {
                _context
                    .read<_StoryLimitController>()
                    .onPageLimitReached(onPageLimitReached);
              } else {
                animateToPage(pageIndex + 1);
              }
            },
            initialStoryIndex: initialStoryIndex,
          ),
        ),
      ],
      child: _StoryPageBuilder._(
        showShadow: showShadow,
        storyLength: storyLength,
        initialStoryIndex: initialStoryIndex,
        pageIndex: pageIndex,
        isCurrentPage: isCurrentPage,
        isPaging: isPaging,
        itemBuilder: itemBuilder,
        gestureItemBuilder: gestureItemBuilder,
        indicatorDuration: indicatorDuration,
        indicatorPadding: indicatorPadding,
        indicatorAnimationController: indicatorAnimationController,
        indicatorVisitedColor: indicatorVisitedColor,
        indicatorUnvisitedColor: indicatorUnvisitedColor,
        indicatorHeight: indicatorHeight,
      ),
    );
  }

  @override
  _StoryPageBuilderState createState() => _StoryPageBuilderState();
}

class _StoryPageBuilderState extends State<_StoryPageBuilder>
    with
        AutomaticKeepAliveClientMixin<_StoryPageBuilder>,
        SingleTickerProviderStateMixin {
  late AnimationController animationController;

  late VoidCallback indicatorListener;
  late VoidCallback imageLoadingListener;

  @override
  void initState() {
    super.initState();

    indicatorListener = () {
      if (widget.isCurrentPage) {
        switch (widget.indicatorAnimationController?.value) {
          case IndicatorAnimationCommand.pause:
            animationController.stop();
            break;
          case IndicatorAnimationCommand.resume:
          default:
            if (storyImageLoadingController.value ==
                StoryImageLoadingState.loading) {
              return;
            }
            animationController.forward();
            break;
        }
      }
    };
    imageLoadingListener = () {
      if (widget.isCurrentPage) {
        switch (storyImageLoadingController.value) {
          case StoryImageLoadingState.loading:
            animationController.stop();
            break;
          case StoryImageLoadingState.available:
            if (widget.indicatorAnimationController?.value ==
                IndicatorAnimationCommand.pause) {
              return;
            }
            animationController.forward();
            break;
        }
      }
    };
    animationController = AnimationController(
      vsync: this,
      duration: widget.indicatorDuration,
    )..addStatusListener(
        (status) {
          if (status == AnimationStatus.completed) {
            context.read<_StoryStackController>().increment(
                restartAnimation: () => animationController.forward(from: 0));
          }
        },
      );
    widget.indicatorAnimationController?.addListener(indicatorListener);
    storyImageLoadingController.addListener(imageLoadingListener);
  }

  @override
  void dispose() {
    widget.indicatorAnimationController?.removeListener(indicatorListener);
    storyImageLoadingController.removeListener(imageLoadingListener);

    super.dispose();
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
            context.watch<_StoryStackController>().value,
          ),
        ),
        Container(
          height: 50,
          decoration: widget.showShadow
              ? BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 10,
                      blurRadius: 20,
                    ),
                  ],
                )
              : null,
        ),
        _Indicators(
          indicatorHeight: widget.indicatorHeight,
          storyLength: widget.storyLength,
          animationController: animationController,
          isCurrentPage: widget.isCurrentPage,
          isPaging: widget.isPaging,
          padding: widget.indicatorPadding,
          indicatorVisitedColor: widget.indicatorVisitedColor,
          indicatorUnvisitedColor: widget.indicatorUnvisitedColor,
          indicatorAnimationController: widget.indicatorAnimationController,
        ),
        _Gestures(
          animationController: animationController,
        ),
        Positioned.fill(
          child: widget.gestureItemBuilder?.call(
                context,
                widget.pageIndex,
                context.watch<_StoryStackController>().value,
              ) ??
              const SizedBox.shrink(),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _Gestures extends StatelessWidget {
  const _Gestures({
    Key? key,
    required this.animationController,
  }) : super(key: key);

  final AnimationController? animationController;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: () {
                animationController!.forward(from: 0);
                context.read<_StoryStackController>().decrement();
              },
              onTapDown: (_) {
                animationController!.stop();
              },
              onTapUp: (_) {
                if (storyImageLoadingController.value !=
                    StoryImageLoadingState.loading) {
                  animationController!.forward();
                }
              },
              onLongPress: () {
                animationController!.stop();
              },
              onLongPressUp: () {
                if (storyImageLoadingController.value !=
                    StoryImageLoadingState.loading) {
                  animationController!.forward();
                }
              },
            ),
          ),
        ),
        Expanded(
          child: Container(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: () {
                context.read<_StoryStackController>().increment(
                      restartAnimation: () =>
                          animationController!.forward(from: 0),
                      completeAnimation: () => animationController!.value = 1,
                    );
              },
              onTapDown: (_) {
                animationController!.stop();
              },
              onTapUp: (_) {
                if (storyImageLoadingController.value !=
                    StoryImageLoadingState.loading) {
                  animationController!.forward();
                }
              },
              onLongPress: () {
                animationController!.stop();
              },
              onLongPressUp: () {
                if (storyImageLoadingController.value !=
                    StoryImageLoadingState.loading) {
                  animationController!.forward();
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _Indicators extends StatefulWidget {
  const _Indicators({
    Key? key,
    required this.animationController,
    required this.storyLength,
    required this.isCurrentPage,
    required this.isPaging,
    required this.padding,
    required this.indicatorUnvisitedColor,
    required this.indicatorVisitedColor,
    required this.indicatorHeight,
    required this.indicatorAnimationController,
  }) : super(key: key);
  final int storyLength;
  final AnimationController? animationController;
  final EdgeInsetsGeometry padding;
  final bool isCurrentPage;
  final bool isPaging;
  final Color indicatorVisitedColor;
  final Color indicatorUnvisitedColor;
  final double indicatorHeight;
  final ValueNotifier<IndicatorAnimationCommand>? indicatorAnimationController;

  @override
  _IndicatorsState createState() => _IndicatorsState();
}

class _IndicatorsState extends State<_Indicators> {
  late Animation<double> indicatorAnimation;

  @override
  void initState() {
    super.initState();
    if (storyImageLoadingController.value != StoryImageLoadingState.loading) {
      widget.animationController!.forward();
    }
    indicatorAnimation =
        Tween(begin: 0.0, end: 1.0).animate(widget.animationController!)
          ..addListener(() {
            setState(() {});
          });
  }

  @override
  Widget build(BuildContext context) {
    final int currentStoryIndex = context.watch<_StoryStackController>().value;
    final bool isStoryEnded = context.watch<_StoryLimitController>().value;
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
        !isStoryEnded &&
        storyImageLoadingController.value != StoryImageLoadingState.loading) {
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
            indicatorHeight: widget.indicatorHeight,
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
    required this.indicatorHeight,
  }) : super(key: key);
  final int index;
  final double value;
  final Color indicatorVisitedColor;
  final Color indicatorUnvisitedColor;
  final double indicatorHeight;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsetsDirectional.only(start: (index == 0) ? 0 : 4),
        child: LinearProgressIndicator(
          value: value,
          backgroundColor: indicatorUnvisitedColor,
          valueColor: AlwaysStoppedAnimation<Color>(indicatorVisitedColor),
          minHeight: indicatorHeight,
        ),
      ),
    );
  }
}

/// Notify current stack index
class _StoryStackController extends ValueNotifier<int> {
  _StoryStackController({
    required this.storyLength,
    required this.onPageForward,
    required this.onPageBack,
    initialStoryIndex = 0,
  }) : super(initialStoryIndex);
  final int storyLength;
  final VoidCallback onPageForward;
  final VoidCallback onPageBack;

  int get limitIndex => storyLength - 1;

  void increment(
      {VoidCallback? restartAnimation, VoidCallback? completeAnimation}) {
    if (value == limitIndex) {
      completeAnimation?.call();
      onPageForward();
    } else {
      value++;
      restartAnimation?.call();
    }
  }

  void decrement() {
    if (value == 0) {
      onPageBack();
    } else {
      value--;
    }
  }
}

class _StoryLimitController extends ValueNotifier<bool> {
  _StoryLimitController() : super(false);

  void onPageLimitReached(VoidCallback? callback) {
    if (!value) {
      callback?.call();
      value = true;
    }
  }
}
