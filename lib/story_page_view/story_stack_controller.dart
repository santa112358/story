import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';

/// Notify current stack index
class StoryStackController extends ValueNotifier<int> {
  StoryStackController({
    @required this.storyLength,
    @required this.onPageForward,
    @required this.onPageBack,
    initialStackIndex = 0,
  }) : super(initialStackIndex);
  final int storyLength;
  final VoidCallback onPageForward;
  final VoidCallback onPageBack;

  int get limitIndex => storyLength - 1;

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
