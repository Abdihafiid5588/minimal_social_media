import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:minimal_social_media/components/like_button.dart';
import 'package:minimal_social_media/components/my_drawer.dart';
import 'package:minimal_social_media/components/my_list_tile.dart';
import 'package:minimal_social_media/components/my_post_button.dart';
import 'package:minimal_social_media/components/my_textfield.dart';
import 'package:minimal_social_media/database/firestore.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreDatabase database = FirestoreDatabase();
  final TextEditingController newPostController = TextEditingController();
  late List<bool> postLikes; // List to store like status for each post

  @override
  void initState() {
    super.initState();
    postLikes = [];

    // Initialize the postLikes list based on the number of posts
    database.getPostsStream().listen((postsSnapshot) {
      setState(() {
        postLikes = List.generate(postsSnapshot.docs.length, (index) => false);
      });
    });
  }

  void postMessage() {
    if (newPostController.text.isNotEmpty) {
      String message = newPostController.text;
      database.addPost(message);
    }
    newPostController.clear();
  }

  void toggleLike(int index, String postId) {
    setState(() {
      postLikes[index] = !postLikes[index];

      if (postLikes[index]) {
        // Add postId to the list of liked posts
        database.addLike(postId);
      } else {
        // Remove postId from the list of liked posts
        database.removeLike(postId);
      }
    });
  }

  void deletePost(String postId) {
    database.deletePost(postId);

    setState(() {
      // Remove postId from the list of liked posts if present
      database.removeLike(postId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text("W A L L"),
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      drawer: const MyDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Row(
              children: [
                Expanded(
                  child: MyTextField(
                    hintText: "Say something.",
                    obscureText: false,
                    controller: newPostController,
                  ),
                ),
                PostButton(
                  onTap: postMessage,
                ),
              ],
            ),
          ),
          StreamBuilder(
            stream: database.getPostsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              final posts = snapshot.data!.docs;

              if (posts.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(25),
                    child: Text("No posts.. post something!"),
                  ),
                );
              }

              return Expanded(
                child: ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    String postId = post.id;
                    String message = post['PostMessage'];
                    String userEmail = post['UserEmail'];
                    Timestamp timestamp = post['TimeStamp'];
                    String formattedDate =
                        DateFormat.yMd().add_Hm().format(timestamp.toDate());

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyListTile(
                            title: message,
                            subTitle: userEmail,
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 25.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  formattedDate,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    deletePost(postId);
                                  },
                                ),
                              ],
                            ),
                          ),
                          LikeButton(
                            isLiked: postLikes[index],
                            onTap: () {
                              toggleLike(index, postId);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
