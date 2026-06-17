import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lookcut_app/models/post_model.dart';
import 'package:lookcut_app/services/post_services.dart';

class EditPostScreen extends StatefulWidget {
  final PostModel post;

  const EditPostScreen({super.key, required this.post});

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  late TextEditingController barberNameController;
  late TextEditingController descriptionController;
  late TextEditingController locationNameController;

  String? base64Image;
  String? latitude;
  String? longitude;
  String? selectedCategory;

  bool isLoading = false;
  bool isGettingLocation = false;

  List<String> get categories {
    return ['Barbershop', 'Fade Cut', 'Pompadour', 'Undercut', 'Hair Tattoo'];
  }

  @override
  void initState() {
    super.initState();

    barberNameController = TextEditingController(
      text: widget.post.barberName ?? '',
    );

    descriptionController = TextEditingController(
      text: widget.post.description ?? '',
    );

    locationNameController = TextEditingController(
      text: widget.post.locationName ?? '',
    );

    base64Image = widget.post.image;
    latitude = widget.post.latitude;
    longitude = widget.post.longitude;
    selectedCategory = widget.post.category;
  }

  @override
  void dispose() {
    barberNameController.dispose();
    descriptionController.dispose();
    locationNameController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();

    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final bytes = await image.readAsBytes();

      if (!mounted) return;

      setState(() {
        base64Image = base64Encode(bytes);
      });
    }
  }

  Future<void> getLocation() async {
    setState(() {
      isGettingLocation = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!mounted) return;

      if (!serviceEnabled) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('GPS belum aktif')));

        setState(() {
          isGettingLocation = false;
        });

        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        if (!mounted) return;
      }

      Position position = await Geolocator.getCurrentPosition();

      if (!mounted) return;

      setState(() {
        latitude = position.latitude.toString();
        longitude = position.longitude.toString();
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }

    if (!mounted) return;

    setState(() {
      isGettingLocation = false;
    });
  }

  void showCategoryBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: categories.map((category) {
              return ListTile(
                leading: const Icon(Icons.content_cut),
                title: Text(category),
                trailing: selectedCategory == category
                    ? const Icon(Icons.check_circle, color: Colors.orange)
                    : null,
                onTap: () {
                  setState(() {
                    selectedCategory = category;
                  });

                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget buildImagePreview() {
    if (base64Image == null) {
      return GestureDetector(
        onTap: pickImage,
        child: Container(
          height: 240,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.grey.shade200,
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image, size: 80),
              SizedBox(height: 10),
              Text("Pilih gambar"),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.memory(
            base64Decode(base64Image!),
            height: 240,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              onPressed: pickImage,
              icon: const Icon(Icons.edit, color: Colors.orange),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> saveEdit() async {
    if (widget.post.id == null) return;

    if (base64Image == null ||
        barberNameController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty ||
        selectedCategory == null ||
        latitude == null ||
        longitude == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Semua data wajib diisi')));
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await PostService.updatePost(widget.post.id!, {
        'image': base64Image,
        'barber_name': barberNameController.text.trim(),
        'description': descriptionController.text.trim(),
        'location_name': locationNameController.text.trim(),
        'category': selectedCategory,
        'latitude': latitude,
        'longitude': longitude,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Posting berhasil diperbarui')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal update: $e')));
    }

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Post")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          buildImagePreview(),

          const SizedBox(height: 20),

          TextField(
            controller: barberNameController,
            decoration: const InputDecoration(labelText: 'Nama Barbershop'),
          ),

          const SizedBox(height: 15),

          TextField(
            controller: descriptionController,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Deskripsi'),
          ),

          const SizedBox(height: 15),

          TextField(
            controller: locationNameController,
            decoration: const InputDecoration(labelText: 'Nama Lokasi'),
          ),

          const SizedBox(height: 15),

          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.category),
            title: Text(selectedCategory ?? 'Pilih Kategori'),
            trailing: const Icon(Icons.keyboard_arrow_down),
            onTap: showCategoryBottomSheet,
          ),

          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.my_location),
            title: Text(
              latitude == null ? 'Ambil Lokasi' : '$latitude, $longitude',
            ),
            trailing: isGettingLocation
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.gps_fixed),
            onTap: isGettingLocation ? null : getLocation,
          ),

          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : saveEdit,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Simpan Perubahan'),
            ),
          ),
        ],
      ),
    );
  }
}
