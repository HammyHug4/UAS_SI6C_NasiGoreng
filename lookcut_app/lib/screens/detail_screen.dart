import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';
import 'package:lookcut_app/l10n/generated/app_localizations.dart';
import 'package:lookcut_app/models/comment_model.dart';
import 'package:lookcut_app/models/post_model.dart';
import 'package:lookcut_app/services/comment_service.dart';
import 'package:lookcut_app/services/favorite_service.dart';
import 'package:lookcut_app/services/post_services.dart';
import 'package:lookcut_app/widgets/comment_tile.dart';

class DetailScreen extends StatefulWidget {
  final PostModel post;

  const DetailScreen({super.key, required this.post});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool isFavorite = false;

  final TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    checkFavorite();
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  // SHARE POST
  void sharePost() {
    SharePlus.instance.share(
      ShareParams(
        text: '${widget.post.barberName}\n\n${widget.post.description}',
      ),
    );
  }

  // DELETE POST
  Future<void> deletePost() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context);

        return AlertDialog(
          title: Text(l10n.deletePost),
          content: Text(l10n.deletePostConfirmation),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await PostService.deletePost(widget.post);

      if (!mounted) return;

      Navigator.pop(context);
    }
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

  // FAVORITE BUTTON
  Future<void> toggleFavorite() async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).pleaseLoginFirst)),
      );

      return;
    }

    if (!isFavorite) {
      await FavoriteService.addFavorite(userId: userId, post: widget.post);

      if (!mounted) return;

      setState(() {
        isFavorite = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).addedToFavorite)),
      );

      return;
    }

    await FavoriteService.removeFavorite(
      userId: userId,
      postId: widget.post.id ?? '',
    );

    if (!mounted) return;

    setState(() {
      isFavorite = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).removedFromFavorite)),
    );
  }

  // ADD COMMENT
  Future<void> addComment() async {
    if (commentController.text.trim().isEmpty) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    final postId = widget.post.id ?? '';

    if (user == null || postId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).pleaseLoginFirst)),
      );

      return;
    }

    final commentText = commentController.text.trim();

    commentController.clear();

    await CommentService.addComment(
      postId: postId,
      userId: user.uid,
      userName: user.displayName ?? user.email ?? 'User',
      comment: commentText,
    );
  }

  // HEADER IMAGE
  Widget buildHeaderImage() {
    final image = buildSafeImage();

    return Stack(
      children: [
        Hero(tag: widget.post.id ?? '', child: image),

        Container(
          height: 320,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.2),
                Colors.black.withValues(alpha: 0.7),
              ],
            ),
          ),
        ),

        Positioned(
          top: 50,
          left: 20,
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back, color: Colors.black),
            ),
          ),
        ),

        Positioned(
          top: 50,
          right: 20,
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  onPressed: sharePost,
                  icon: const Icon(Icons.share, color: Colors.black),
                ),
              ),
              const SizedBox(width: 10),
              CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  onPressed: toggleFavorite,
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ),

        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
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
              const SizedBox(height: 12),
              Text(
                widget.post.barberName ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.person, color: Colors.white70, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    widget.post.userFullName ?? '',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildSafeImage() {
    final image = widget.post.image;

    if (image == null || image.isEmpty) {
      return buildImagePlaceholder();
    }

    try {
      return Image.memory(
        base64Decode(image),
        width: double.infinity,
        height: 320,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => buildImagePlaceholder(),
      );
    } on FormatException {
      return buildImagePlaceholder();
    }
  }

  Widget buildImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 320,
      color: Colors.grey.shade300,
      child: const Center(
        child: Icon(Icons.image_not_supported, size: 72, color: Colors.grey),
      ),
    );
  }

  Widget buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.orange.shade100,
            child: Icon(icon, color: Colors.orange.shade800),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(color: Colors.grey.shade700, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildOwnerActions() {
    final isOwner =
        FirebaseAuth.instance.currentUser?.uid == widget.post.userId;
    final l10n = AppLocalizations.of(context);

    if (!isOwner) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: deletePost,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          icon: const Icon(Icons.delete),
          label: Text(l10n.deletePost),
        ),
      ),
    );
  }

  Widget buildCommentSection() {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.comments,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: commentController,
                decoration: InputDecoration(
                  hintText: l10n.writeComment,
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            CircleAvatar(
              backgroundColor: Colors.orange,
              child: IconButton(
                onPressed: addComment,
                icon: const Icon(Icons.send, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        StreamBuilder<List<CommentModel>>(
          stream: CommentService.getCommentsByPost(widget.post.id ?? ''),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Text(
                snapshot.error.toString(),
                style: const TextStyle(color: Colors.red),
              );
            }

            final comments = snapshot.data ?? [];

            if (comments.isEmpty) {
              return Text(
                l10n.noCommentsYet,
                style: TextStyle(color: Colors.grey.shade600),
              );
            }

            return Column(
              children: comments
                  .map(
                    (comment) => CommentTile(
                      comment: comment,
                      onDelete: () {
                        CommentService.deleteComment(comment.id ?? '');
                      },
                      onEdit: (newComment) {
                        CommentService.updateComment(
                          commentId: comment.id ?? '',
                          newComment: newComment,
                        );
                      },
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            buildHeaderImage(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.post.description ?? '',
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 20),
                  buildInfoCard(
                    icon: Icons.category,
                    title: l10n.category,
                    value: widget.post.category ?? '-',
                  ),
                  const SizedBox(height: 12),
                  buildInfoCard(
                    icon: Icons.location_on,
                    title: l10n.location,
                    value:
                        '${widget.post.latitude ?? '-'}, ${widget.post.longitude ?? '-'}',
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MapDetailScreen(post: widget.post),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.map),
                      label: Text(l10n.viewMap),
                    ),
                  ),
                  buildOwnerActions(),
                  const SizedBox(height: 26),
                  buildCommentSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
