import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? uid;
  String? fullName;
  String? email;
  String? photoBase64;

  UserModel({
    this.uid,
    this.fullName,
    this.email,
    this.photoBase64,
  });

  factory UserModel.fromDocument(DocumentSnapshot doc) {
    final data =
        doc.data() as Map<String, dynamic>? ?? {};

    return UserModel(
      uid: doc.id,
      fullName: data['full_name'],
      email: data['email'],
      photoBase64: data['photo_base64'],
    );
  }

  Map<String, dynamic> toDocument() {
    final data = <String, dynamic>{
      'full_name': fullName,
      'email': email,
      'updated_at': Timestamp.now(),
    };

    if (photoBase64 != null) {
      data['photo_base64'] = photoBase64;
    }

    return data;
  }
}
