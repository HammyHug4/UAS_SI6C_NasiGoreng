import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  String? id;
  String? comment;
  String? userId;
  String? userName;
  String? postId;
  Timestamp? createdAt;

  CommentModel({
    this.id,
    this.comment,
    this.userId,
    this.userName,
    this.postId,
    this.createdAt,
  });
}
