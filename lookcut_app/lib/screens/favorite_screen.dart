import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lookcut_app/l10n/generated/app_localizations.dart';
import 'package:lookcut_app/models/post_model.dart';
import 'package:lookcut_app/services/favorite_service.dart';
import 'package:lookcut_app/screens/detail_screen.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  // REMOVE FAVORITE
  Future<void> removeFavorite(PostModel post) async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    await FavoriteService.removeFavorite(userId: userId, postId: post.id ?? '');

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).removedFromFavorite)),
    );
  }

  Widget buildSafeImage(PostModel post) {
    final image = post.image;

    if (image == null || image.isEmpty) {
      return buildImagePlaceholder();
    }

    try {
      return Image.memory(
        base64Decode(image),
        height: 220,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => buildImagePlaceholder(),
      );
    } on FormatException {
      return buildImagePlaceholder();
    }
  }

  Widget buildImagePlaceholder() {
    return Container(
      height: 220,
      width: double.infinity,
      color: Colors.grey.shade300,
      child: const Center(
        child: Icon(Icons.image_not_supported, size: 64, color: Colors.grey),
      ),
    );
  }

  // EMPTY FAVORITE UI
  Widget buildEmptyFavorite() {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 120, color: Colors.grey.shade400),
          const SizedBox(height: 20),
          Text(
            l10n.noFavoriteYet,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.saveFavoriteHere,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
        ],
      ),
    );
  }

  // FAVORITE CARD UI
  Widget buildFavoriteCard(PostModel post) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailScreen(post: post)),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: 88,
                height: 88,
                child: buildSafeImage(post),
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.barberName ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    post.category ?? '-',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.orange.shade800,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

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
                          '${post.latitude ?? '-'}, ${post.longitude ?? '-'}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            IconButton(
              onPressed: () {
                removeFavorite(post);
              },
              icon: Icon(Icons.favorite, color: Colors.red.shade600),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.favorite)),
      body: user == null
          ? Center(child: Text(l10n.pleaseLoginFirst))
          : StreamBuilder<List<PostModel>>(
              stream: FavoriteService.getFavorites(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                }

                final favoritePosts = snapshot.data ?? [];

                if (favoritePosts.isEmpty) {
                  return buildEmptyFavorite();
                }

                return ListView.builder(
                  itemCount: favoritePosts.length,
                  itemBuilder: (context, index) {
                    return buildFavoriteCard(favoritePosts[index]);
                  },
                );
              },
            ),
    );
  }
}
