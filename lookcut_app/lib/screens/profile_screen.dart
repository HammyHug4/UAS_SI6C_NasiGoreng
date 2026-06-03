import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lookcut_app/l10n/generated/app_localizations.dart';
import 'package:lookcut_app/models/user_model.dart';
import 'package:lookcut_app/provider/language_provider.dart';
import 'package:lookcut_app/provider/theme_provider.dart';
import 'package:lookcut_app/services/user_service.dart';
import 'package:lookcut_app/screens/sign_in_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState
    extends State<ProfileScreen> {

  bool isSaving = false;
  bool hasEnsuredUserDocument = false;

  // GENERATE AVATAR
  String generateAvatarUrl(String? fullName) {
    final formattedName =
        (fullName ?? 'User')
            .trim()
            .replaceAll(' ', '+');

    return 'https://ui-avatars.com/api/?name=$formattedName&background=ff9800&color=ffffff&size=256';
  }

  Future<void> ensureUserDocument(User user) async {
    await UserService.saveUser(
      UserModel(
        uid: user.uid,
        fullName:
            user.displayName ??
            user.email ??
            'User',
        email: user.email,
      ),
    );
  }

  ImageProvider buildAvatarImage({
    required User? user,
    required UserModel? profile,
  }) {
    final photoBase64 = profile?.photoBase64;

    if (photoBase64 != null && photoBase64.isNotEmpty) {
      try {
        return MemoryImage(
          base64Decode(photoBase64),
        );
      } on FormatException {
        return NetworkImage(
          generateAvatarUrl(
            profile?.fullName ?? user?.displayName,
          ),
        );
      }
    }

    return NetworkImage(
      generateAvatarUrl(
        profile?.fullName ?? user?.displayName,
      ),
    );
  }

  Future<void> pickProfilePhoto() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 60,
      maxWidth: 700,
    );

    if (image == null) {
      return;
    }

    final bytes = await image.readAsBytes();
    final base64Photo = base64Encode(bytes);

    await UserService.updateProfile(
      uid: user.uid,
      fullName:
          user.displayName ??
          user.email ??
          'User',
      email: user.email ?? '',
      photoBase64: base64Photo,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)
              .profilePhotoUpdated,
        ),
      ),
    );
  }

  Future<void> showEditProfileDialog(
    UserModel? profile,
  ) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    final nameController =
        TextEditingController(
      text:
          profile?.fullName ??
          user.displayName ??
          '',
    );

    final emailController =
        TextEditingController(
      text:
          profile?.email ??
          user.email ??
          '',
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context);

        return AlertDialog(
          title: Text(l10n.editProfile),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: l10n.fullName,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: emailController,
                keyboardType:
                    TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: l10n.email,
                ),
              ),
            ],
          ),
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
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );

    if (result != true) {
      nameController.dispose();
      emailController.dispose();
      return;
    }

    final fullName =
        nameController.text.trim();
    final email =
        emailController.text.trim();

    nameController.dispose();
    emailController.dispose();

    if (fullName.isEmpty || email.isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)
                .pleaseCompleteAllFields,
          ),
        ),
      );

      return;
    }

    setState(() {
      isSaving = true;
    });

    await user.updateDisplayName(fullName);

    if (email != user.email) {
      try {
        await user.verifyBeforeUpdateEmail(email);
      } on FirebaseAuthException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(
            SnackBar(
              content: Text(
                e.message ??
                    AppLocalizations.of(context)
                        .failedToUpdateEmail,
              ),
            ),
          );
        }
      }
    }

    await UserService.updateProfile(
      uid: user.uid,
      fullName: fullName,
      email: email,
    );

    await user.reload();

    if (!mounted) return;

    setState(() {
      isSaving = false;
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context).profileUpdated,
        ),
      ),
    );
  }

  Future<void> showLanguageDialog() async {
    final l10n = AppLocalizations.of(context);
    final languageProvider = LanguageProvider.instance;

    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.selectLanguage,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.translate),
                  title: Text(l10n.indonesian),
                  trailing:
                      languageProvider.languageCode == 'id'
                          ? const Icon(
                              Icons.check,
                              color: Colors.orange,
                            )
                          : null,
                  onTap: () async {
                    await languageProvider.setLocale(
                      const Locale('id'),
                    );

                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(l10n.english),
                  trailing:
                      languageProvider.languageCode == 'en'
                          ? const Icon(
                              Icons.check,
                              color: Colors.orange,
                            )
                          : null,
                  onTap: () async {
                    await languageProvider.setLocale(
                      const Locale('en'),
                    );

                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // LOGOUT
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const SignInScreen(),
      ),
      (route) => false,
    );
  }

  // PROFILE HEADER
  Widget buildProfileHeader(
    UserModel? profile,
  ) {
    final user = FirebaseAuth.instance.currentUser;
    final fullName =
        profile?.fullName ??
        user?.displayName ??
        'User';
    final email =
        profile?.email ??
        user?.email ??
        '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        top: 30,
        left: 20,
        right: 20,
        bottom: 30,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.shade400,
            Colors.deepOrange.shade500,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(35),
          bottomRight: Radius.circular(35),
        ),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: buildAvatarImage(
                  user: user,
                  profile: profile,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: pickProfilePhoto,
                    icon: const Icon(
                      Icons.camera_alt,
                      size: 18,
                      color: Colors.orange,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            fullName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            email,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // STATISTIC ITEM
  Widget buildStatisticItem(
    String value,
    String title,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  // MENU TILE
  Widget buildMenuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius:
            BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 6,
        ),
        leading: CircleAvatar(
          backgroundColor:
              (color ?? Colors.orange)
                  .withValues(alpha: 0.1),
          child: Icon(
            icon,
            color: color ?? Colors.orange,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 18,
        ),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        body: Center(
          child: Text(
            AppLocalizations.of(context)
                .pleaseLoginFirst,
          ),
        ),
      );
    }

    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: StreamBuilder<UserModel?>(
        stream: UserService.getUser(user.uid),
        builder: (context, snapshot) {
          final profile = snapshot.data;

          if (snapshot.connectionState ==
                  ConnectionState.active &&
              profile == null &&
              !hasEnsuredUserDocument) {
            hasEnsuredUserDocument = true;
            ensureUserDocument(user);
          }

          return Stack(
            children: [
              ListView(
                padding: EdgeInsets.zero,
                children: [
                  buildProfileHeader(profile),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        buildMenuTile(
                          icon: Icons.edit,
                          title: l10n.editProfile,
                          onTap: () {
                            showEditProfileDialog(
                              profile,
                            );
                          },
                        ),
                        buildMenuTile(
                          icon: Icons.dark_mode,
                          title: ThemeProvider
                                  .instance
                                  .isDarkMode
                              ? l10n.darkModeOn
                              : l10n.darkModeOff,
                          onTap: () {
                            ThemeProvider
                                .instance
                                .toggleTheme();
                          },
                        ),
                        buildMenuTile(
                          icon: Icons.language,
                          title:
                              '${l10n.language}: ${LanguageProvider.instance.isIndonesian ? l10n.indonesian : l10n.english}',
                          onTap: showLanguageDialog,
                        ),

                        buildMenuTile(
                          icon: Icons.logout,
                          title: l10n.logout,
                          color: Colors.red,
                          onTap: logout,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (isSaving)
                Container(
                  color: Colors.black
                      .withValues(alpha: 0.25),
                  child: const Center(
                    child:
                        CircularProgressIndicator(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
