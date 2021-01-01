class StoryContent {
  StoryContent(this.settings, {this.initialStackIndex = 0});
  final int initialStackIndex;
  final List<StorySetting> settings;
}

class StorySetting {
  StorySetting({this.indicatorDuration});

  final Duration indicatorDuration;
}
