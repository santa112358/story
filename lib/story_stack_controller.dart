import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';

class StoryStackController extends ValueNotifier<int> {
  StoryStackController({
    @required this.stackLength,
    @required this.onPageForward,
    @required this.onPageBack,
  }) : super(0);
  final int stackLength;
  final VoidCallback onPageForward;
  final VoidCallback onPageBack;
  int get limitIndex => stackLength - 1;

  AnimationController animationController;

  void increment({VoidCallback stopAnimation}) {
    if (value == limitIndex) {
      onPageForward?.call();
      stopAnimation?.call();
    } else {
      value++;
    }
  }

  void decrement({VoidCallback stopAnimation}) {
    if (value == 0) {
      onPageBack?.call();
      stopAnimation?.call();
    } else {
      value--;
    }
  }
}
