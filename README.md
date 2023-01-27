<p align="center">
  <a href="https://pub.dev/packages/story">
    <img src="https://raw.githubusercontent.com/santa112358/story/v1.0.0/logo/story.png" width="320px"/>
  </a>
</p>
<p align="center">
<a><img src="https://img.shields.io/badge/all_contributors-6-orange.svg?style=flat-square" alt="all contributors"></a>
<a href="(https://pub.dev/packages/story"><img src="https://img.shields.io/pub/v/story.svg" alt="all contributors"></a>
<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>
</p>

Instagram stories like UI with rich animations and customizability.

![final 2](https://user-images.githubusercontent.com/43510799/103445017-8e497300-4cb2-11eb-8bed-97a7d98461da.gif)

## Usage

`StoryPageView` requires at least three arguments: `itemBuilder`, `pageLength`, and `storyLength`.

``` dart
/// Minimum example to explain the usage.
return Scaffold(
  body: StoryPageView(
    itemBuilder: (context, pageIndex, storyIndex) {
      return Center(
        child: Text("Index of PageView: $pageIndex Index of story on each page: $storyIndex"),
      );
    },
    storyLength: (pageIndex) {
      return 3;
    },
    pageLength: 4,
  );
```

- `itemBuilder` builds the content of each story and is called with the index of the pageView and
  the index of the story on the page.

- `storyLength` decides the length of story for each page. The example above always returns 3, but
  it should depend on `pageIndex`.

- `pageLength` is just the length of `StoryPageView`

The example above just shows 12 stories by 4 pages, which is not practical.

This one is the proper usage, extracted from [example](https://pub.dev/packages/story/example).

``` dart
return Scaffold(
  body: StoryPageView(
    itemBuilder: (context, pageIndex, storyIndex) {
      final user = sampleUsers[pageIndex];
      final story = user.stories[storyIndex];
      return Stack(
        children: [
          Positioned.fill(
            child: Container(color: Colors.black),
          ),
          Positioned.fill(
            child: Image.network(
              story.imageUrl,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 44, left: 8),
            child: Row(
              children: [
                Container(
                  height: 32,
                  width: 32,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(user.imageUrl),
                      fit: BoxFit.cover,
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                Text(
                  user.userName,
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    },
    gestureItemBuilder: (context, pageIndex, storyIndex) {
      return Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.only(top: 32),
          child: IconButton(
            padding: EdgeInsets.zero,
            color: Colors.white,
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      );
    },
    pageLength: sampleUsers.length,
    storyLength: (int pageIndex) {
      return sampleUsers[pageIndex].stories.length;
    },
    onPageLimitReached: () {
      Navigator.pop(context);
    },
  ),
);
```

- `gestureItemBuilder` builds widgets that need gesture actions

In this case, IconButton to close the page is in the callback.

You **CANNOT** place the gesture widgets in `itemBuilder` as they are covered and disabled by the
default story gestures.

- `onPageLimitReached` is called when the very last story is finished.

- It is recommended to use data model with two layers. In this case, `UserModel` which has the list
  of `StoryModel`

```dart
/// Example Data Model
class UserModel {
  UserModel(this.stories, this.userName, this.imageUrl);

  final List<StoryModel> stories;
  final String userName;
  final String imageUrl;
}

class StoryModel {
  StoryModel(this.imageUrl);

  final String imageUrl;
}
```

### StoryImage

If you show images in `StoryPageView`, use `StoryImage`. It can stop the indicator until the image
is fully loaded.

``` dart
StoryImage(
  /// key is required
  key: ValueKey(story.imageUrl),
  imageProvider: NetworkImage(
    story.imageUrl,
  ),
  fit: BoxFit.fitWidth,
)
```

Be sure to assign the unique key value for each image, otherwise the image loading will not be
handled properly.

### indicatorAnimationController

If you stop/start the animation of the story with your custom widgets,
use `indicatorAnimationController`

``` dart
class _StoryPageState extends State<StoryPage> {
  late ValueNotifier<IndicatorAnimationCommand> indicatorAnimationController;

  @override
  void initState() {
    super.initState();
    indicatorAnimationController = ValueNotifier<IndicatorAnimationCommand>(
        IndicatorAnimationCommand.resume);
  }

  @override
  void dispose() {
    indicatorAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StoryPageView(
        indicatorAnimationController: indicatorAnimationController,
        ...,
      ),
    );
  }
}
```

Once the instance is passed to `StoryPageView`, you can stop handle the indicator by the methods
below.

```dart

/// To pause the indicator
indicatorAnimationController.value = IndicatorAnimationCommand.pause;

/// To resume the indicator
indicatorAnimationController.value = IndicatorAnimationCommand.resume;

```

## Contributors

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tbody>
    <tr>
      <td align="center"><a href="https://pub.dev/publishers/3tadev.work/packages"><img src="https://avatars.githubusercontent.com/u/43510799?v=4?s=100" width="100px;" alt="Santa Takahashi"/><br /><sub><b>Santa Takahashi</b></sub></a><br /><a href="https://github.com/santa112358/story/commits?author=santa112358" title="Code">💻</a></td>
      <td align="center"><a href="https://github.com/imejiasoft"><img src="https://avatars.githubusercontent.com/u/44923350?v=4?s=100" width="100px;" alt="Isaias Mejia de los Santos"/><br /><sub><b>Isaias Mejia de los Santos</b></sub></a><br /><a href="https://github.com/santa112358/story/commits?author=imejiasoft" title="Code">💻</a></td>
      <td align="center"><a href="https://github.com/badgentlemen"><img src="https://avatars.githubusercontent.com/u/29949358?v=4?s=100" width="100px;" alt="Медик"/><br /><sub><b>Медик</b></sub></a><br /><a href="https://github.com/santa112358/story/commits?author=badgentlemen" title="Code">💻</a></td>
      <td align="center"><a href="https://github.com/alperensoysall"><img src="https://avatars.githubusercontent.com/u/107396431?v=4?s=100" width="100px;" alt="Alperen Soysal"/><br /><sub><b>Alperen Soysal</b></sub></a><br /><a href="https://github.com/santa112358/story/commits?author=alperensoysall" title="Code">💻</a></td>
      <td align="center"><a href="https://github.com/AtixD"><img src="https://avatars.githubusercontent.com/u/17594120?v=4?s=100" width="100px;" alt="AtixD"/><br /><sub><b>AtixD</b></sub></a><br /><a href="https://github.com/santa112358/story/commits?author=AtixD" title="Code">💻</a></td>
      <td align="center"><a href="https://github.com/harshitFinmapp"><img src="https://avatars.githubusercontent.com/u/110468872?v=4?s=100" width="100px;" alt="harshitFinmapp"/><br /><sub><b>harshitFinmapp</b></sub></a><br /><a href="https://github.com/santa112358/story/commits?author=harshitFinmapp" title="Code">💻</a></td>
    </tr>
  </tbody>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->
<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->