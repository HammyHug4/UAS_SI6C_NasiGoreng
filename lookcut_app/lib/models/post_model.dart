import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  String? id;
  String? image;
  String? barberName;
  String? description;
  String? category;
  String? latitude;
  String? longitude;
  String? userId;
  String? userFullName;
  Timestamp? createdAt;

  PostModel({
    this.id,
    this.image,
    this.barberName,
    this.description,
    this.category,
    this.latitude,
    this.longitude,
    this.userId,
    this.userFullName,
    this.createdAt,
  });

  factory PostModel.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data =
        doc.data() as Map<String, dynamic>;

    return PostModel(
      id: doc.id,
      image: data['image'],
      barberName: data['barber_name'],
      description: data['description'],
      category: data['category'],
      latitude: data['latitude'],
      longitude: data['longitude'],
      userId: data['user_id'],
      userFullName: data['user_full_name'],
      createdAt: data['created_at'],
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      'image': image,
      'barber_name': barberName,
      'description': description,
      'category': category,
      'latitude': latitude,
      'longitude': longitude,
      'user_id': userId,
      'user_full_name': userFullName,
      'created_at': Timestamp.now(),
    };
  }
}