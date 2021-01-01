import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';

class StoryStackController extends ValueNotifier<int> {
  StoryStackController({
    @required this.stackLength,
    @required this.onPageForward,
    @required this.onPageBack,
    initialStackIndex = 0,
  }) : super(initialStackIndex);
  final int stackLength;
  final VoidCallback onPageForward;
  final VoidCallback onPageBack;

  int get limitIndex => stackLength - 1;

  AnimationController animationController;

  void increment(
      {VoidCallback restartAnimation, VoidCallback completeAnimation}) {
    if (value == limitIndex) {
      completeAnimation?.call();
      onPageForward?.call();
    } else {
      value++;
      restartAnimation?.call();
    }
  }

  void decrement() {
    if (value == 0) {
      onPageBack?.call();
    } else {
      value--;
    }
  }
}
