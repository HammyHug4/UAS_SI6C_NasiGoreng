import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lookcut_app/models/user_model.dart';
import 'package:lookcut_app/l10n/generated/app_localizations.dart';
import 'package:lookcut_app/services/post_services.dart';
import 'package:lookcut_app/services/user_service.dart';
import 'package:lookcut_app/widgets/post_list_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  String? selectedCategory;

  final TextEditingController searchController =
      TextEditingController();

  List<String> get categories {
    return [
      'Barbershop',
      'Fade Cut',
      'Pompadour',
      'Undercut',
      'Hair Tattoo',
    ];
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // Logout Firebase
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  // Generate avatar user
  String generateAvatarUrl(String? fullName) {
    final formattedName =
        (fullName ?? 'User')
            .trim()
            .replaceAll(' ', '+');

    return 'https://ui-avatars.com/api/?name=$formattedName&background=ff9800&color=ffffff&size=256';
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

  // BottomSheet Filter Category
  void showCategoryFilter() async {
    final l10n = AppLocalizations.of(context);

    final result = await showModalBottomSheet<String?>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      builder: (context) {
        return SafeArea(
  child: SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  l10n.selectCategory,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.clear),
                title: Text(l10n.allCategory),
                onTap: () {
                  Navigator.pop(context, null);
                },
              ),
              const Divider(),
              ...categories.map(
                (category) {
                  return ListTile(
                    leading: const Icon(Icons.cut),
                    title: Text(category),
                    trailing:
                        selectedCategory == category
                            ? const Icon(
                                Icons.check_circle,
                                color: Colors.orange,
                              )
                            : null,
                    onTap: () {
                      Navigator.pop(
                        context,
                        category,
                      );
                    },
                  );
                },
              ),
            ],
          ),
    ),
  ),
        );
      },
    );

    setState(() {
      selectedCategory = result;
    });
  }

  // HEADER UI
  Widget buildHeader() {
    final user = FirebaseAuth.instance.currentUser;
    final l10n = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        top: 20,
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
          StreamBuilder<UserModel?>(
            stream: user == null
                ? const Stream.empty()
                : UserService.getUser(user.uid),
            builder: (context, snapshot) {
              final profile = snapshot.data;
              final fullName =
                  profile?.fullName ??
                  user?.displayName ??
                  '';
              final email =
                  profile?.email ??
                  user?.email ??
                  '';

              return Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundImage: buildAvatarImage(
                      user: user,
                      profile: profile,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.welcomeBack,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          fullName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: const TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 25),

          // SEARCH BAR
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(18),
            ),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText:
                    l10n.searchBarbershop,
                prefixIcon:
                    const Icon(Icons.search),
                suffixIcon: IconButton(
                  onPressed: showCategoryFilter,
                  icon: const Icon(
                    Icons.filter_list,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          if (selectedCategory != null) ...[
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerLeft,
              child: Chip(
                backgroundColor: Colors.white,
                avatar: const Icon(
                  Icons.filter_list,
                  size: 18,
                  color: Colors.orange,
                ),
                label: Text(
                  selectedCategory!,
                  style: TextStyle(
                    color: Colors.orange.shade800,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                deleteIcon: const Icon(
                  Icons.close,
                  size: 18,
                ),
                onDeleted: () {
                  setState(() {
                    selectedCategory = null;
                  });
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget buildPostList() {
    final l10n = AppLocalizations.of(context);

    return StreamBuilder(
      stream: PostService.getPostList(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return SliverFillRemaining(
            child: Center(
              child: Text(
                snapshot.error.toString(),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final searchText = searchController.text.toLowerCase();
        final posts = (snapshot.data ?? []).where((post) {
          final category = selectedCategory;
          final postCategory = post.category?.trim().toLowerCase() ?? '';

          if (category != null &&
              postCategory != category.trim().toLowerCase()) {
            return false;
          }

          if (searchText.isEmpty) {
            return true;
          }

          return (post.barberName ?? '').toLowerCase().contains(searchText) ||
              (post.description ?? '').toLowerCase().contains(searchText);
        }).toList();

        if (posts.isEmpty) {
          return SliverFillRemaining(
            child: Center(child: Text(l10n.noPostsFound)),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => PostListItem(post: posts[index]),
            childCount: posts.length,
          ),
        );
      },
    );
  }

  Widget buildHomeTab() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: buildHeader()),
        buildPostList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pages = [
      buildHomeTab(),
      const FavoriteScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: SafeArea(child: pages[currentIndex]),
      floatingActionButton: currentIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddPostScreen()),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: l10n.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.favorite),
            label: l10n.favorite,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: l10n.profile,
          ),
        ],
      ),
    );
  }
}
