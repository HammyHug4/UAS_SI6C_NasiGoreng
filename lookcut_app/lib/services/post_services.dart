import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lookcut_app/models/post_model.dart';

class PostService {
  static CollectionReference postCollection = FirebaseFirestore.instance
      .collection('posts');

  static Future<void> addPost(PostModel post) async {
    try {
      await postCollection.add(post.toDocument());
    } catch (e) {
      debugPrint('Add Post Error : $e');
    }
  }

  static Stream<List<PostModel>> getPostList() {
    return postCollection
        .orderBy('created_at', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => PostModel.fromDocument(doc)).toList(),
        );
  }

  static Stream<List<PostModel>> getPostByCategory(String category) {
    return postCollection
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) {
          final posts = snapshot.docs
              .map((doc) => PostModel.fromDocument(doc))
              .toList();

          posts.sort((a, b) {
            final aDate = a.createdAt?.toDate();
            final bDate = b.createdAt?.toDate();

            if (aDate == null && bDate == null) {
              return 0;
            }

            if (aDate == null) {
              return 1;
            }

            if (bDate == null) {
              return -1;
            }

            return bDate.compareTo(aDate);
          });

          return posts;
        });
  }

  static Stream<List<PostModel>> getUserPosts(String userId) {
    return postCollection
        .where('user_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => PostModel.fromDocument(doc)).toList(),
        );
  }

  static Future<PostModel?> getSinglePost(String postId) async {
    try {
      final DocumentSnapshot document = await postCollection.doc(postId).get();

      return PostModel.fromDocument(document);
    } catch (e) {
      debugPrint('Get Single Post Error : $e');

      return null;
    }
  }

  static Future<void> deletePost(PostModel post) async {
    if (post.id == null) {
      return;
    }

    try {
      await postCollection.doc(post.id).delete();
    } catch (e) {
      debugPrint('Delete Post Error : $e');
    }
  }
}
