import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lookcut_app/l10n/generated/app_localizations.dart';
import 'package:lookcut_app/models/post_model.dart';
import 'package:lookcut_app/services/post_services.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final TextEditingController barberNameController = TextEditingController();

  final TextEditingController descriptionController = TextEditingController();

  final TextEditingController locationNameController = TextEditingController();

  String? base64Image;

  String? latitude;
  String? longitude;

  String? selectedCategory;

  bool isSubmitting = false;
  bool isGettingLocation = false;

  List<String> get categories {
    return ['Barbershop', 'Fade Cut', 'Pompadour', 'Undercut', 'Hair Tattoo'];
  }

  @override
  void dispose() {
    barberNameController.dispose();
    descriptionController.dispose();
    locationNameController.dispose();
    super.dispose();
  }

  // PICK IMAGE
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();

    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final bytes = await image.readAsBytes();

      setState(() {
        base64Image = base64Encode(bytes);
      });
    }
  }

  // GET LOCATION
  Future<void> getLocation() async {
    setState(() {
      isGettingLocation = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).gpsDisabled)),
        );

        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      Position position = await Geolocator.getCurrentPosition();

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

    setState(() {
      isGettingLocation = false;
    });
  }

  // SELECT CATEGORY
  void showCategoryBottomSheet() {
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  l10n.chooseCategory,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ...categories.map((category) {
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
              }),
            ],
          ),
        );
      },
    );
  }

  // IMAGE PREVIEW
  Widget buildImagePreview() {
    final l10n = AppLocalizations.of(context);

    if (base64Image == null) {
      return GestureDetector(
        onTap: pickImage,
        child: Container(
          height: 240,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.grey.shade200,
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.image, size: 80, color: Colors.grey),
              const SizedBox(height: 14),
              Text(
                l10n.uploadBarbershopImage,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Image.memory(
            base64Decode(base64Image!),
            width: double.infinity,
            height: 240,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 14,
          right: 14,
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

  Future<void> submitPost() async {
    final user = FirebaseAuth.instance.currentUser;

    if (base64Image == null ||
        barberNameController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty ||
        selectedCategory == null ||
        latitude == null ||
        longitude == null ||
        user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).pleaseCompleteAllFields),
        ),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    await PostService.addPost(
      PostModel(
        image: base64Image,
        barberName: barberNameController.text.trim(),
        description: descriptionController.text.trim(),
        category: selectedCategory,
        locationName: locationNameController.text.trim(),
        latitude: latitude,
        longitude: longitude,
        userId: user.uid,
        userFullName: user.displayName ?? user.email ?? 'User',
      ),
    );

    if (!mounted) return;

    setState(() {
      isSubmitting = false;
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.addPost)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          buildImagePreview(),
          const SizedBox(height: 20),
          TextField(
            controller: barberNameController,
            decoration: InputDecoration(labelText: l10n.barbershopName),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: descriptionController,
            maxLines: 4,
            decoration: InputDecoration(labelText: l10n.description),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: locationNameController,
            decoration: InputDecoration(labelText: l10n.locationName),
          ),
          const SizedBox(height: 14),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.category),
            title: Text(selectedCategory ?? l10n.chooseCategory),
            trailing: const Icon(Icons.keyboard_arrow_down),
            onTap: showCategoryBottomSheet,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.my_location),
            title: Text(
              latitude == null || longitude == null
                  ? l10n.getCurrentLocation
                  : '$latitude, $longitude',
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
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: isSubmitting ? null : submitPost,
            child: Text(isSubmitting ? l10n.saving : l10n.savePost),
          ),
        ],
      ),
    );
  }
}
