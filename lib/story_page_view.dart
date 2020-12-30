import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:story/story_stack_controller.dart';

class StoryPageView extends StatefulWidget {
  StoryPageView({Key key, this.initialPage = 0}) : super(key: key);

  final initialPage;

  @override
  _StoryPageViewState createState() => _StoryPageViewState();
}

class _StoryPageViewState extends State<StoryPageView> {
  PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: widget.initialPage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: pageController,
        itemCount: 4,
        itemBuilder: (context, index) {
          return StoryPageFrame.wrapped(
            pageController: pageController,
            pageLength: 4,
            stackLength: 5,
            pageIndex: index,
            jumpPage: (index) {
              pageController.jumpToPage(index);
            },
          );
        },
      ),
    );
  }
}

class StoryPageFrame extends StatefulWidget {
  const StoryPageFrame._({Key key, @required this.stackLength})
      : super(key: key);
  final int stackLength;

  static Widget wrapped({
    @required int pageIndex,
    @required int pageLength,
    @required PageController pageController,
    @required ValueChanged<int> jumpPage,
    @required int stackLength,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_context) => StoryStackController(
            stackLength: stackLength,
            onPageBack: () {
              if (pageIndex == 0) {
                print("reach 0");
              } else {
                jumpPage(pageIndex - 1);
              }
            },
            onPageForward: () {
              if (pageIndex == pageLength - 1) {
                print("reach limit");
              } else {
                jumpPage(pageIndex + 1);
              }
            },
          ),
        ),
      ],
      child: StoryPageFrame._(stackLength: stackLength),
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
    animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 5));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      fit: StackFit.loose,
      alignment: Alignment.topLeft,
      children: [
        Indicators(
          stackLength: widget.stackLength,
          animationController: animationController,
        ),
        IndexedStack(
          index: context.watch<StoryStackController>().value,
          children: List.generate(
            context.watch<StoryStackController>().value + 1,
            (index) => Center(
              child: Text(
                index.toString(),
              ),
            ),
          ),
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
                animationController.reset();
                animationController.forward();
                context
                    .read<StoryStackController>()
                    .decrement(stopAnimation: () => animationController.stop());
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
                animationController.reset();
                animationController.forward();
                context
                    .read<StoryStackController>()
                    .increment(stopAnimation: () => animationController.stop());
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
  }) : super(key: key);
  final int stackLength;
  final AnimationController animationController;

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
                context.read<StoryStackController>().increment();
                widget.animationController.forward(from: 0);
              }
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = context.watch<StoryStackController>().value;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
          widget.stackLength,
          (index) => _Indicator(
            index: index,
            value: (index == currentIndex)
                ? indicatorAnimation.value
                : (index > currentIndex)
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
        child: LinearProgressIndicator(value: value),
      ),
    );
  }
}
