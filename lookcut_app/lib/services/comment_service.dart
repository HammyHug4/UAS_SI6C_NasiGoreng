import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lookcut_app/models/comment_model.dart';

class CommentService {
  static CollectionReference commentCollection = FirebaseFirestore.instance
      .collection('comments');
  static Future<void> addComment({
    required String postId,
    required String userId,
    required String userName,
    required String comment,
  }) async {
    if (postId.isEmpty || userId.isEmpty || comment.trim().isEmpty) {
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
      debugPrint('Add Comment Error : $e');
    }
  }

  static Stream<List<CommentModel>> getCommentsByPost(String postId) {
    return commentCollection
        .where('post_id', isEqualTo: postId)
        .snapshots()
        .map((snapshot) {
          final comments = snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;

            return CommentModel(
              id: doc.id,
              comment: data['comment'],
              userId: data['user_id'],
              userName: data['user_name'],
              postId: data['post_id'],
              createdAt: data['created_at'],
            );
          }).toList();

          comments.sort((a, b) {
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

          return comments;
        });
  }

  static Future<void> deleteComment(String commentId) async {
    try {
      await commentCollection.doc(commentId).delete();
    } catch (e) {
      debugPrint('Delete Comment Error : $e');
    }
  }

  static Future<void> updateComment({
    required String commentId,
    required String newComment,
  }) async {
    try {
      await commentCollection.doc(commentId).update({
        'comment': newComment,
        'updated_at': Timestamp.now(),
      });
    } catch (e) {
      debugPrint('Update Comment Error : $e');
    }
  }
}
