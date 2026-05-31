import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lookcut_app/l10n/generated/app_localizations.dart';
import 'package:lookcut_app/models/comment_model.dart';

class CommentTile extends StatefulWidget {
  final CommentModel comment;

  final VoidCallback? onDelete;
  final Function(String)? onEdit;
  final Function(String)? onReply;

  const CommentTile({
    super.key,
    required this.comment,
    this.onDelete,
    this.onEdit,
    this.onReply,
  });

  @override
  State<CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<CommentTile> {
  // GENERATE AVATAR
  String generateAvatarUrl(String? fullName) {
    final formattedName = (fullName ?? 'User').trim().replaceAll(' ', '+');

    return 'https://ui-avatars.com/api/?name=$formattedName&background=ff9800&color=ffffff&size=256';
  }

  // EDIT COMMENT
  void showEditDialog() {
    final TextEditingController editController = TextEditingController(
      text: widget.comment.comment,
    );

    showDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context);

        return AlertDialog(
          title: Text(l10n.editComment),

          content: TextField(
            controller: editController,
            maxLines: 3,
            decoration: InputDecoration(hintText: l10n.updateComment),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(l10n.cancel),
            ),

            ElevatedButton(
              onPressed: () {
                if (widget.onEdit != null) {
                  widget.onEdit!(editController.text);
                }

                Navigator.pop(context);
              },
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );
  }

  // COMMENT HEADER
  Widget buildCommentHeader() {
    final l10n = AppLocalizations.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // AVATAR
        CircleAvatar(
          radius: 22,
          backgroundImage: NetworkImage(
            generateAvatarUrl(widget.comment.userName),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // USERNAME
              Text(
                widget.comment.userName ?? '',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              // COMMENT
              Text(
                widget.comment.comment ?? '',
                style: TextStyle(color: Colors.grey.shade800, height: 1.5),
              ),
            ],
          ),
        ),

        // MENU
        if (FirebaseAuth.instance.currentUser?.uid == widget.comment.userId)
          PopupMenuButton(
            itemBuilder: (context) {
              return [
                PopupMenuItem(value: 'edit', child: Text(l10n.edit)),

                PopupMenuItem(value: 'delete', child: Text(l10n.delete)),
              ];
            },

            onSelected: (value) {
              if (value == 'edit') {
                showEditDialog();
              }

              if (value == 'delete') {
                if (widget.onDelete != null) {
                  widget.onDelete!();
                }
              }
            },
          ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [buildCommentHeader()],
      ),
    );
  }
}
