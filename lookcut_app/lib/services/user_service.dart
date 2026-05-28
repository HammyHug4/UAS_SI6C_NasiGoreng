import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lookcut_app/models/user_model.dart';

class UserService {
  static CollectionReference userCollection = FirebaseFirestore.instance
      .collection('users');

  static Stream<UserModel?> getUser(String uid) {
    return userCollection.doc(uid).snapshots().map((document) {
      if (!document.exists) {
        return null;
      }

      return UserModel.fromDocument(document);
    });
  }

  static Future<void> saveUser(UserModel user) async {
    if (user.uid == null || user.uid!.isEmpty) {
      return;
    }

    try {
      await userCollection
          .doc(user.uid)
          .set(user.toDocument(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('Save User Error : $e');
    }
  }

  static Future<void> updateProfile({
    required String uid,
    required String fullName,
    required String email,
    String? photoBase64,
  }) async {
    if (uid.isEmpty) {
      return;
    }

    try {
      final data = <String, dynamic>{
        'full_name': fullName,
        'email': email,
        'updated_at': Timestamp.now(),
      };

      if (photoBase64 != null) {
        data['photo_base64'] = photoBase64;
      }

      await userCollection.doc(uid).set(data, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Update Profile Error : $e');
    }
  }
}
