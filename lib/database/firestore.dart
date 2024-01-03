import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreDatabase {
  User? user = FirebaseAuth.instance.currentUser;
  final CollectionReference posts = FirebaseFirestore.instance.collection('Posts');

  Future<void> addPost(String message) {
    return posts.add({
      'UserEmail': user!.email,
      'PostMessage': message,
      'TimeStamp': Timestamp.now(),
      'Likes': [], // Initialize Likes as an empty array for each post
    });
  }

  Stream<QuerySnapshot> getPostsStream() {
    final postsStream = FirebaseFirestore.instance
        .collection('Posts')
        .orderBy('TimeStamp', descending: true)
        .snapshots();

    return postsStream;
  }

  Future<void> deletePost(String postId) {
    return posts.doc(postId).delete();
  }

  Future<void> addLike(String postId) {
    return posts.doc(postId).update({
      'Likes': FieldValue.arrayUnion([user!.email]),
    });
  }

  Future<void> removeLike(String postId) {
    return posts.doc(postId).update({
      'Likes': FieldValue.arrayRemove([user!.email]),
    });
  }
}
