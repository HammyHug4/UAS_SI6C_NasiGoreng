import 'package:flutter/material.dart';
import 'package:lookcut_app/models/post_model.dart';
import 'package:lookcut_app/services/post_services.dart';

class EditPostScreen extends StatefulWidget {
  final PostModel post;

  const EditPostScreen({super.key, required this.post});

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  late TextEditingController barberController;
  late TextEditingController descriptionController;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    barberController = TextEditingController(
      text: widget.post.barberName ?? '',
    );

    descriptionController = TextEditingController(
      text: widget.post.description ?? '',
    );
  }

  @override
  void dispose() {
    barberController.dispose();
    descriptionController.dispose();

    super.dispose();
  }

  Future<void> saveEdit() async {
    if (widget.post.id == null) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    await PostService.updatePost(widget.post.id!, {
      'barber_name': barberController.text,

      'description': descriptionController.text,
    });

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    Navigator.pop(context);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Posting berhasil diupdate')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Post')),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            TextField(
              controller: barberController,

              decoration: const InputDecoration(
                labelText: 'Nama Barbershop',

                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: descriptionController,

              maxLines: 5,

              decoration: const InputDecoration(
                labelText: 'Deskripsi',

                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: isLoading ? null : saveEdit,

                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Simpan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
