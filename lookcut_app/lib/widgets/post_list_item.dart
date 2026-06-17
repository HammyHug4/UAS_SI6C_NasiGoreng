import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lookcut_app/l10n/generated/app_localizations.dart';
import 'package:lookcut_app/models/post_model.dart';
import 'package:lookcut_app/services/favorite_service.dart';
import 'package:lookcut_app/screens/detail_screen.dart';
import 'package:lookcut_app/screens/edit_post_screen.dart';
import 'package:lookcut_app/services/post_services.dart';

class PostListItem extends StatefulWidget {
  final PostModel post;
  final double? userLatitude;
  final double? userLongitude;
  final bool isLoadingUserLocation;

  const PostListItem({
    super.key,
    required this.post,
    this.userLatitude,
    this.userLongitude,
    this.isLoadingUserLocation = false,
  });

  @override
  State<PostListItem> createState() => _PostListItemState();
}

class _PostListItemState extends State<PostListItem> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();

    checkFavorite();
  }

  // CHECK FAVORITE
  Future<void> checkFavorite() async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    final favorite = await FavoriteService.isFavorite(
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
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).pleaseLoginFirst)),
      );

      return;
    }

    // ADD FAVORITE
    if (!isFavorite) {
      await FavoriteService.addFavorite(userId: userId, post: widget.post);

      setState(() {
        isFavorite = true;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).addedToFavorite)),
      );
    }
    // REMOVE FAVORITE
    else {
      await FavoriteService.removeFavorite(
        userId: userId,
        postId: widget.post.id ?? '',
      );

      setState(() {
        isFavorite = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).removedFromFavorite),
        ),
      );
    }
  }

  // FORMAT DATE
  String formatDate() {
    final createdAt = widget.post.createdAt;

    if (createdAt == null) {
      return AppLocalizations.of(context).recently;
    }

    final date = createdAt.toDate();

    return '${date.day}/${date.month}/${date.year}';
  }

  String? formatDistanceEstimate() {
    final userLatitude = widget.userLatitude;
    final userLongitude = widget.userLongitude;
    final postLatitude = double.tryParse(widget.post.latitude ?? '');
    final postLongitude = double.tryParse(widget.post.longitude ?? '');

    if (userLatitude == null ||
        userLongitude == null ||
        postLatitude == null ||
        postLongitude == null) {
      return null;
    }

    final distanceInMeters = Geolocator.distanceBetween(
      userLatitude,
      userLongitude,
      postLatitude,
      postLongitude,
    );

    final distanceInKm = distanceInMeters / 1000;
    final formattedDistance = distanceInKm < 10
        ? distanceInKm.toStringAsFixed(1)
        : distanceInKm.toStringAsFixed(0);

    return '$formattedDistance km ${AppLocalizations.of(context).fromYourLocation}';
  }

  Widget buildDistanceEstimate() {
    final distanceText = formatDistanceEstimate();

    if (widget.isLoadingUserLocation) {
      return Row(
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.orange.shade700,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            AppLocalizations.of(context).calculatingDistance,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
          ),
        ],
      );
    }

    if (distanceText == null) {
      return Row(
        children: [
          Icon(Icons.near_me_disabled, color: Colors.grey.shade600, size: 18),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              AppLocalizations.of(context).distanceUnavailable,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Icon(Icons.near_me, color: Colors.orange.shade700, size: 18),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            distanceText,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // USER AVATAR
  String generateAvatarUrl(String? fullName) {
    final formattedName = (fullName ?? 'User').trim().replaceAll(' ', '+');

    return 'https://ui-avatars.com/api/?name=$formattedName&background=ff9800&color=ffffff&size=256';
  }

  // SAFE IMAGE
  Widget buildSafeImage() {
    final image = widget.post.image;

    if (image == null || image.isEmpty) {
      return buildImagePlaceholder();
    }

    try {
      return Image.memory(
        base64Decode(image),
        width: double.infinity,
        height: 240,
        fit: BoxFit.cover,

        errorBuilder: (context, error, stackTrace) {
          return buildImagePlaceholder();
        },
      );
    } on FormatException {
      return buildImagePlaceholder();
    }
  }

  // IMAGE PLACEHOLDER
  Widget buildImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 240,

      color: Colors.grey.shade300,

      child: const Center(
        child: Icon(Icons.image_not_supported, size: 64, color: Colors.grey),
      ),
    );
  }

  // CARD IMAGE
  Widget buildPostImage() {
    final image = buildSafeImage();

    return Stack(
      children: [
        Hero(
          tag: widget.post.id ?? '',

          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),

            child: image,
          ),
        ),

        // GRADIENT
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),

              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,

                colors: [
                  Colors.black.withValues(alpha: 0.1),

                  Colors.black.withValues(alpha: 0.5),
                ],
              ),
            ),
          ),
        ),

        // CATEGORY
        Positioned(
          top: 16,
          left: 16,

          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),

            decoration: BoxDecoration(
              color: Colors.orange,

              borderRadius: BorderRadius.circular(30),
            ),

            child: Text(
              widget.post.category ?? '',

              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        // FAVORITE BUTTON
        Positioned(
          top: 16,
          right: 16,

          child: CircleAvatar(
            backgroundColor: Colors.white,

            child: IconButton(
              onPressed: toggleFavorite,

              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,

                color: Colors.red,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // USER INFO
  Widget buildUserInfo() {
    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        CircleAvatar(
          radius: 22,

          backgroundImage: NetworkImage(
            generateAvatarUrl(widget.post.userFullName),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(
                widget.post.userFullName ?? '',

                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                formatDate(),

                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ],
          ),
        ),

        // OWNER MENU
        if (FirebaseAuth.instance.currentUser?.uid == widget.post.userId)
          PopupMenuButton(
            onSelected: (value) {
              if (value == 'edit') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditPostScreen(post: widget.post),
                  ),
                );
              }

              if (value == 'delete') {
                PostService.deletePost(widget.post);
              }
            },

            itemBuilder: (context) {
              return [
                PopupMenuItem(value: 'edit', child: Text(l10n.edit)),

                PopupMenuItem(value: 'delete', child: Text(l10n.delete)),
              ];
            },
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,

          MaterialPageRoute(builder: (_) => DetailScreen(post: widget.post)),
        ).then((_) {
          checkFavorite();
        });
      },

      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(24),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),

              blurRadius: 10,

              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            buildPostImage(),

            Padding(
              padding: const EdgeInsets.all(18),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  buildUserInfo(),

                  const SizedBox(height: 14),

                  // BARBER NAME
                  Text(
                    widget.post.barberName ?? '',

                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // DESCRIPTION
                  Text(
                    widget.post.description ?? '',

                    maxLines: 2,

                    overflow: TextOverflow.ellipsis,

                    style: TextStyle(color: Colors.grey.shade700, height: 1.5),
                  ),

                  const SizedBox(height: 14),

                  // LOCATION
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,

                        color: Colors.orange.shade700,

                        size: 20,
                      ),

                      const SizedBox(width: 6),

                      Expanded(
                        child: Text(
                          '${widget.post.latitude ?? '-'}, ${widget.post.longitude ?? '-'}',

                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  buildDistanceEstimate(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
