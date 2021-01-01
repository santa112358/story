import 'package:flutter/material.dart';
import 'package:story/story_page_view.dart';

void main() {
  runApp(MyApp());
}

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

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key key}) : super(key: key);

  final sampleUsers = [
    UserModel([
      StoryModel(""),
      StoryModel(""),
      StoryModel(""),
      StoryModel(""),
    ], "Santa", ""),
    UserModel([
      StoryModel(""),
      StoryModel(""),
      StoryModel(""),
      StoryModel(""),
    ], "Santa", ""),
    UserModel([
      StoryModel(""),
      StoryModel(""),
      StoryModel(""),
      StoryModel(""),
    ], "Santa", ""),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StoryPageView(
        itemBuilder: (context, pageIndex, stackIndex) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "pageIndex: ${pageIndex.toString()}",
                  style: TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 12),
                Text(
                  "stackIndex: ${stackIndex.toString()}",
                  style: TextStyle(fontSize: 24),
                ),
              ],
            ),
          );
        },
        pageLength: sampleUsers.length,
        stackLength: (int pageIndex) {
          return sampleUsers[pageIndex].stories.length;
        },
      ),
    );
  }
}
