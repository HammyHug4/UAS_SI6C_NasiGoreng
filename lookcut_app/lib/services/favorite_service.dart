import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pangkas_mbut/models/post_model.dart';

class FavoriteService {
  static CollectionReference favoriteCollection =
      FirebaseFirestore.instance.collection(
    'favorites',
  );

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
      await favoriteCollection.doc(
        favoriteDocumentId(
          userId: userId,
          postId: postId,
        ),
      ).set({
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
      debugPrint(
        'Add Favorite Error : $e',
      );
    }
  }