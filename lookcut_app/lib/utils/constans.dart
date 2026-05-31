import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'LookCut Maps';
  static const String appVersion = '1.0.0';
  static const String appDeveloper = 'LookCut Developer';

  static const String postCollection = 'posts';
  static const String commentCollection = 'comments';
  static const String favoriteCollection = 'favorites';
  static const String userCollection = 'users';

  static const double padding = 16;
  static const double largePadding = 24;
  static const double smallPadding = 10;
  static const double borderRadius = 18;
  static const double cardRadius = 24;
  static const double buttonHeight = 56;

  static const Color primaryColor = Colors.orange;
  static const Color secondaryColor = Colors.deepOrange;
  static const Color whiteColor = Colors.white;
  static const Color blackColor = Colors.black;
  static const Color greyColor = Colors.grey;
  static const Color redColor = Colors.red;
  static const Color greenColor = Colors.green;

  static const Color darkBackground = Color(0xff121212);
  static const Color darkCard = Color(0xff1E1E1E);

  static const TextStyle headingStyle = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle titleStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle subtitleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle bodyStyle = TextStyle(fontSize: 15);

  static const Duration animationDuration = Duration(milliseconds: 300);

  static const double defaultZoom = 15;

  static const String avatarBaseUrl = 'https://ui-avatars.com/api/?name=';

  static const String imagePlaceholder = 'https://via.placeholder.com/300';

  static const String noPostMessage = 'No Barbershop Found';
  static const String noFavoriteMessage = 'No Favorite Yet';
  static const String noCommentMessage = 'No Comment Yet';

  static const String successAddPost = 'Post Added Successfully';
  static const String successDeletePost = 'Post Deleted Successfully';
  static const String successAddFavorite = 'Added to Favorite';
  static const String successRemoveFavorite = 'Removed from Favorite';

  static const String errorMessage = 'Something went wrong';
  static const String networkError = 'No internet connection';
  static const String locationError = 'Failed to get location';

  static const List<String> categories = [
    'Barbershop',
    'Fade Cut',
    'Pompadour',
    'Undercut',
    'Hair Tattoo',
  ];

  static const List<Map<String, dynamic>> profileMenus = [
    {'title': 'Edit Profile', 'icon': Icons.person},
    {'title': 'Dark Mode', 'icon': Icons.dark_mode},
    {'title': 'Favorite', 'icon': Icons.favorite},
    {'title': 'Settings', 'icon': Icons.settings},
    {'title': 'Help Center', 'icon': Icons.help},
    {'title': 'Logout', 'icon': Icons.logout},
  ];
}
