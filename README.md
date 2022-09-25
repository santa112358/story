# story
<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-1-orange.svg?style=flat-square)](#contributors-)
<!-- ALL-CONTRIBUTORS-BADGE:END -->

[![pub package](https://img.shields.io/pub/v/story.svg)](https://pub.dev/packages/story)
<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>

Instagram stories like UI with rich animations and customizability.

![final 2](https://user-images.githubusercontent.com/43510799/103445017-8e497300-4cb2-11eb-8bed-97a7d98461da.gif)

## Usage

`StoryPageView` needs at least three arguments: `itemBuilder`, `pageLength`, and `storyLength`.
```dart
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
- `itemBuilder` is necessary to build the content of story. It is called with index of pageView and index of the story on the page.

- `storyLength` decides the length of story for each page. The example above always returns 3, but it should depend on the argument `pageIndex`

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
- `gestureItemBuilder` is the builder for the widgets which needs gesture actions.

In this case, IconButton to close the page is in the callback.

You **CANNOT** place the gesture widgets in `itemBuilder` because it is covered and disabled by default story gestures.

- `onPageLimitReached` is called when the very last story is finished.

- It is recommended to use data model with two layers. In this case, `UserModel` which has the list of `StoryModel`

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


## Tips

This package is still under development. If you have any requests or questions, please ask on [github](https://github.com/santa112358/story/issues)


## Contributors
[![All Contributors](https://img.shields.io/badge/all_contributors-13-orange.svg?style=flat-square)](#contributors)

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tbody>
    <tr>
      <td align="center"><a href="https://pub.dev/publishers/3tadev.work/packages"><img src="https://avatars.githubusercontent.com/u/43510799?v=4?s=100" width="100px;" alt="Santa Takahashi"/><br /><sub><b>Santa Takahashi</b></sub></a><br /><a href="https://github.com/santa112358/story/commits?author=santa112358" title="Code">💻</a></td>
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