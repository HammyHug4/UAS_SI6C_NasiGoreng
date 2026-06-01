import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pangkas_rambut/l10n/generated/app_localizations.dart';
import 'package:pangkas_rambut/models/post_model.dart';
import 'package:pangkas_rambut/services/favorite_service.dart';
import 'package:pangkas_rambut/screens/detail_screen.dart';

class PostListItem extends StatefulWidget {
  final PostModel post;

  const PostListItem({
    super.key,
    required this.post,
  });

  @override
  State<PostListItem> createState() =>
      _PostListItemState();
}

class _PostListItemState
    extends State<PostListItem> {

  bool isFavorite = false;

  @override
  void initState() {
    super.initState();

    checkFavorite();
  }

    // CHECK FAVORITE
  Future<void> checkFavorite() async {

    final userId =
        FirebaseAuth
                .instance
                .currentUser
                ?.uid ??
            '';

    final favorite =
        await FavoriteService.isFavorite(
      userId: userId,
      postId: widget.post.id ?? '',
    );

    if (!mounted) return;

    setState(() {
      isFavorite = favorite;
    });
  }

  // TOGGLE FAVORITE
  Future<void> toggleFavorite() async {

    final userId =
        FirebaseAuth
                .instance
                .currentUser
                ?.uid ??
            '';

    if (userId.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)
                .pleaseLoginFirst,
          ),
        ),
      );

      return;
    }
  }