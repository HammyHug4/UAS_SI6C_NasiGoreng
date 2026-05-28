import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lookcut_app/models/post_model.dart';

class FavoriteService {
  static CollectionReference favoriteCollection = FirebaseFirestore.instance
      .collection('favorites');
  static String favoriteDocumentId({
    required String userId,
    required String postId,
  }) {
    return '${userId}_$postId';
  }

  static Future<void> addFavorite({
    required String userId,
    required PostModel post,
  }) async {
    final postId = post.id;

    if (userId.isEmpty || postId == null || postId.isEmpty) {
      return;
    }

    try {
      await favoriteCollection
          .doc(favoriteDocumentId(userId: userId, postId: postId))
          .set({
            'user_id': userId,
            'post_id': postId,
            'image': post.image,
            'barber_name': post.barberName,
            'description': post.description,
            'category': post.category,
            'latitude': post.latitude,
            'longitude': post.longitude,
            'post_user_id': post.userId,
            'user_full_name': post.userFullName,
            'created_at': Timestamp.now(),
          });
    } catch (e) {
      debugPrint('Add Favorite Error : $e');
    }
  }

  static Stream<List<PostModel>> getFavorites(String userId) {
    return favoriteCollection
        .where('user_id', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final posts = snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;

            return PostModel(
              id: data['post_id'],
              image: data['image'],
              barberName: data['barber_name'],
              description: data['description'],
              category: data['category'],
              latitude: data['latitude'],
              longitude: data['longitude'],
              userId: data['post_user_id'],
              userFullName: data['user_full_name'],
              createdAt: data['created_at'],
            );
          }).toList();

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

  static Future<void> removeFavorite({
    required String userId,
    required String postId,
  }) async {
    if (userId.isEmpty || postId.isEmpty) {
      return;
    }
    try {
      await favoriteCollection
          .doc(favoriteDocumentId(userId: userId, postId: postId))
          .delete();

      final favoriteSnapshot = await favoriteCollection
          .where('user_id', isEqualTo: userId)
          .where('post_id', isEqualTo: postId)
          .get();

      for (var document in favoriteSnapshot.docs) {
        await favoriteCollection.doc(document.id).delete();
      }
    } catch (e) {
      debugPrint('Remove Favorite Error : $e');
    }
  }

  static Future<bool> isFavorite({
    required String userId,
    required String postId,
  }) async {
    if (userId.isEmpty || postId.isEmpty) {
      return false;
    }

    try {
      final favoriteDocument = await favoriteCollection
          .doc(favoriteDocumentId(userId: userId, postId: postId))
          .get();

      if (favoriteDocument.exists) {
        return true;
      }

      final favoriteSnapshot = await favoriteCollection
          .where('user_id', isEqualTo: userId)
          .where('post_id', isEqualTo: postId)
          .get();

      return favoriteSnapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint('Check Favorite Error : $e');
      return false;
    }
  }
}
