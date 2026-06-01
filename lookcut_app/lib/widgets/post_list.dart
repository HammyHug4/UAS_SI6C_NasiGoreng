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
    }