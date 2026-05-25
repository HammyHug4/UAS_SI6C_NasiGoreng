import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
//import 'package:pangkas_mbut/models/comment_model.dart';

class CommentService {

  // COLLECTION
  static CollectionReference commentCollection =
      FirebaseFirestore.instance.collection(
    'comments',
  );

  // ADD COMMENT
  static Future<void> addComment({
    required String postId,
    required String userId,
    required String userName,
    required String comment,
  }) async {
    if (postId.isEmpty ||
        userId.isEmpty ||
        comment.trim().isEmpty) {
      return;
    }

    try {
      await commentCollection.add({
        'post_id': postId,
        'user_id': userId,
        'user_name': userName,
        'comment': comment,
        'created_at': Timestamp.now(),
      });

    } catch (e) {
      debugPrint(
        'Add Comment Error : $e',
      );
    }
  }

  // DELETE COMMENT
  static Future<void> deleteComment(
    String commentId,
  ) async {

    try {
      await commentCollection
          .doc(commentId)
          .delete();

    } catch (e) {
      debugPrint(
        'Delete Comment Error : $e',
      );
    }
  }

  // UPDATE COMMENT
  static Future<void> updateComment({
    required String commentId,
    required String newComment,
  }) async {

    try {
      await commentCollection
          .doc(commentId)
          .update({
        'comment': newComment,
        'updated_at': Timestamp.now(),
      });

    } catch (e) {
      debugPrint(
        'Update Comment Error : $e',
      );
    }
  }
}
