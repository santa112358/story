import 'package:flutter/cupertino.dart';

class StoryLimitController extends ValueNotifier<bool> {
  StoryLimitController() : super(false);

  void onPageLimitReached(VoidCallback? callback) {
    if (!value) {
      callback?.call();
      value = true;
    }
  }
}
