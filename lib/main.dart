
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/app_theme.dart';
import 'core/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseService.initialize();

runApp(const SafeSpaceApp());
}

// ============================================================
// APP THEME
// ============================================================

class AppColors {
  static const background = Color(0xFF0F1513);
  static const surface = Color(0xFF18221F);
  static const surfaceLight = Color(0xFF202C27);
  static const emerald = Color(0xFF00A878);
  static const emeraldDark = Color(0xFF087653);
  static const text = Color(0xFFF1F5F2);
  static const muted = Color(0xFF91A39A);
  static const border = Color(0xFF293832);
  static const danger = Color(0xFFE57373);
}

class SafeSpaceApp extends StatelessWidget {
  const SafeSpaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Safe Space',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.emerald,
          secondary: Color(0xFF6ED6AC),
          surface: AppColors.surface,
          error: AppColors.danger,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.text,
          elevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.border),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceLight,
          hintStyle: const TextStyle(color: AppColors.muted),
          labelStyle: const TextStyle(color: AppColors.muted),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColors.emerald,
              width: 1.5,
            ),
          ),
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: AppColors.surfaceLight,
          contentTextStyle: TextStyle(color: AppColors.text),
        ),
        bottomNavigationBarTheme:
            const BottomNavigationBarThemeData(
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.emerald,
          unselectedItemColor: AppColors.muted,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
      ),
      home: const PhoneAuthScreen(),
    );
  }
}

// ============================================================
// USER PROFILE MODEL
// ============================================================

class UserProfile {
  final String name;
  final String role;
  final String location;
  final String bio;

  const UserProfile({
    required this.name,
    required this.role,
    required this.location,
    required this.bio,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? 'Safe Space Member',
      role: json['role'] ?? 'Community Member',
      location: json['location'] ?? 'Kenya',
      bio: json['bio'] ?? 'Welcome to my Safe Space profile.',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'role': role,
      'location': location,
      'bio': bio,
    };
  }
}

// ============================================================
// LOGIN SCREEN - DEMO OTP
// ============================================================

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  bool otpRequested = false;
  bool loading = false;

  @override
  void dispose() {
    phoneController.dispose();
    otpController.dispose();
    super.dispose();
  }

  Future<void> requestOtp() async {
    if (phoneController.text.trim().isEmpty) {
      showMessage(context, 'Enter your phone number.');
      return;
    }

    setState(() => loading = true);

    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    setState(() {
      loading = false;
      otpRequested = true;
    });

    showMessage(context, 'Demo mode: use OTP 123456.');
  }

  Future<void> verifyOtp() async {
    if (otpController.text.trim() != '123456') {
      showMessage(context, 'Incorrect demo OTP.');
      return;
    }

    setState(() => loading = true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const MainNavigationContainer(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(26),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 64,
                  width: 64,
                  decoration: BoxDecoration(
                    color: AppColors.emerald.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.people_alt_rounded,
                    color: AppColors.emerald,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Safe Space',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Born in Kenya. Built for the world.',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 48),
                const Text(
                  'Your community starts here.',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Connect, share ideas, discover opportunities '
                  'and build meaningful communities.',
                  style: TextStyle(
                    color: AppColors.muted,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.phone_outlined),
                    labelText: 'Phone number',
                    hintText: '+254...',
                  ),
                ),
                if (otpRequested) ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.lock_outline),
                      labelText: 'Demo OTP',
                      hintText: 'Enter 123456',
                      counterText: '',
                    ),
                  ),
                ],
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: loading
                        ? null
                        : otpRequested
                            ? verifyOtp
                            : requestOtp,
                    child: loading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            otpRequested
                                ? 'Verify and continue'
                                : 'Continue',
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    'Prototype login — no SMS is sent yet.',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// POST AND COMMENT MODELS
// ============================================================

class CommentItem {
  final String author;
  final String text;
  final String time;

  CommentItem({
    required this.author,
    required this.text,
    required this.time,
  });

  Map<String, dynamic> toJson() => {
        'author': author,
        'text': text,
        'time': time,
      };

  factory CommentItem.fromJson(Map<String, dynamic> json) {
    return CommentItem(
      author: json['author'] ?? 'Member',
      text: json['text'] ?? '',
      time: json['time'] ?? 'Just now',
    );
  }
}

class PostItem {
  final String id;
  final String author;
  final String role;
  final String location;
  final String category;
  final String content;
  final String? mediaPath;
  final String mediaType;
  final String time;
  final List<String> likes;
  final List<CommentItem> comments;

  PostItem({
    required this.id,
    required this.author,
    required this.role,
    required this.location,
    required this.category,
    required this.content,
    this.mediaPath,
    this.mediaType = 'none',
    required this.time,
    List<String>? likes,
    List<CommentItem>? comments,
  })  : likes = likes ?? [],
        comments = comments ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author': author,
      'role': role,
      'location': location,
      'category': category,
      'content': content,
      'mediaPath': mediaPath,
      'mediaType': mediaType,
      'time': time,
      'likes': likes,
      'comments': comments.map((e) => e.toJson()).toList(),
    };
  }

  factory PostItem.fromJson(Map<String, dynamic> json) {
    return PostItem(
      id: json['id'] ?? '',
      author: json['author'] ?? 'Member',
      role: json['role'] ?? 'Community Member',
      location: json['location'] ?? 'Kenya',
      category: json['category'] ?? 'General',
      content: json['content'] ?? '',
      mediaPath: json['mediaPath'],
      mediaType: json['mediaType'] ?? 'none',
      time: json['time'] ?? 'Recently',
      likes: List<String>.from(json['likes'] ?? []),
      comments: (json['comments'] as List? ?? [])
          .map((e) => CommentItem.fromJson(
                Map<String, dynamic>.from(e),
              ))
          .toList(),
    );
  }
}

// ============================================================
// MAIN NAVIGATION
// ============================================================

class MainNavigationContainer extends StatefulWidget {
  const MainNavigationContainer({super.key});

  @override
  State<MainNavigationContainer> createState() =>
      _MainNavigationContainerState();
}

class _MainNavigationContainerState
    extends State<MainNavigationContainer> {
  int currentIndex = 0;
  bool profileLoaded = false;

  UserProfile profile = const UserProfile(
    name: 'Safe Space Member',
    role: 'Community Member',
    location: 'Kenya',
    bio: 'Welcome to my Safe Space profile.',
  );

  List<PostItem> posts = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    UserProfile loadedProfile = profile;
    final profileString = prefs.getString('safe_profile');

    if (profileString != null) {
      try {
        loadedProfile = UserProfile.fromJson(
          jsonDecode(profileString),
        );
      } catch (_) {}
    }

    List<PostItem> loadedPosts = [];
    final postsString = prefs.getString('saved_community_posts');

    if (postsString != null) {
      try {
        final decoded = jsonDecode(postsString) as List;
        loadedPosts = decoded
            .map((e) => PostItem.fromJson(
                  Map<String, dynamic>.from(e),
                ))
            .toList();
      } catch (_) {}
    }

    if (!mounted) return;

    setState(() {
      profile = loadedProfile;
      posts = loadedPosts;
      profileLoaded = true;
    });
  }

  Future<void> saveProfile(UserProfile updated) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'safe_profile',
      jsonEncode(updated.toJson()),
    );

    if (!mounted) return;

    setState(() => profile = updated);
  }

  Future<void> savePosts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'saved_community_posts',
      jsonEncode(posts.map((e) => e.toJson()).toList()),
    );
  }

  void addPost(PostItem post) {
    setState(() => posts.insert(0, post));
    savePosts();
  }

  void updatePost(PostItem updated) {
    final index = posts.indexWhere((p) => p.id == updated.id);
    if (index == -1) return;

    setState(() => posts[index] = updated);
    savePosts();
  }

  void openCreatePost() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (_) => CreatePostSheet(
        profile: profile,
        onPostCreated: addPost,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!profileLoaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final screens = [
      HomeScreen(
        profile: profile,
        posts: posts,
        onCreatePost: openCreatePost,
        onPostUpdated: updatePost,
      ),
      const ResourcesHubScreen(),
      const DirectMessagesScreen(),
      ProfileScreen(
        profile: profile,
        onProfileUpdated: saveProfile,
        onLogout: () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('is_logged_in', false);

          if (!mounted) return;

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => const PhoneAuthScreen(),
            ),
            (route) => false,
          );
        },
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ============================================================
// HOME FEED
// ============================================================

class HomeScreen extends StatefulWidget {
  final UserProfile profile;
  final List<PostItem> posts;
  final VoidCallback onCreatePost;
  final Function(PostItem) onPostUpdated;

  const HomeScreen({
    super.key,
    required this.profile,
    required this.posts,
    required this.onCreatePost,
    required this.onPostUpdated,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = 'All';

  final categories = const [
    'All',
    'Mechanics & Tech',
    'Business & Trade',
    'General',
  ];

  @override
  Widget build(BuildContext context) {
    final filteredPosts = selectedCategory == 'All'
        ? widget.posts
        : widget.posts
            .where((p) => p.category == selectedCategory)
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Safe Space',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Your world. Your community.',
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 11,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationsScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: widget.onCreatePost,
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 400));
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
          children: [
            _welcomeCard(),
            const SizedBox(height: 20),
            _createPostPrompt(),
            const SizedBox(height: 22),
            const Text(
              'Explore your feed',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                  final category = categories[index];
                  final selected = category == selectedCategory;

                  return ChoiceChip(
                    label: Text(category),
                    selected: selected,
                    onSelected: (_) {
                      setState(() => selectedCategory = category);
                    },
                    selectedColor: AppColors.emerald,
                    backgroundColor: AppColors.surface,
                    labelStyle: TextStyle(
                      color: selected
                          ? Colors.white
                          : AppColors.muted,
                    ),
                    side: const BorderSide(
                      color: AppColors.border,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 18),
            if (filteredPosts.isEmpty)
              _emptyFeed()
            else
              ...filteredPosts.map(
                (post) => PostCard(
                  post: post,
                  onLike: () {
                    final updated = PostItem(
                      id: post.id,
                      author: post.author,
                      role: post.role,
                      location: post.location,
                      category: post.category,
                      content: post.content,
                      mediaPath: post.mediaPath,
                      mediaType: post.mediaType,
                      time: post.time,
                      likes: List<String>.from(post.likes),
                      comments: List<CommentItem>.from(post.comments),
                    );

                    const currentUser = 'You';

                    if (updated.likes.contains(currentUser)) {
                      updated.likes.remove(currentUser);
                    } else {
                      updated.likes.add(currentUser);
                    }

                    widget.onPostUpdated(updated);
                  },
                  onOpen: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PostDetailScreen(
                          post: post,
                          onPostUpdated: widget.onPostUpdated,
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _welcomeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF087653),
            Color(0xFF123F30),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'WELCOME TO YOUR SPACE',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Hello, ${widget.profile.name}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Share knowledge. Discover opportunities. '
            'Connect with people who understand your world.',
            style: TextStyle(
              color: Colors.white,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Icon(Icons.public, color: Colors.white70, size: 16),
              SizedBox(width: 6),
              Text(
                'Born in Kenya. Built for the world.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _createPostPrompt() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: AppColors.emeraldDark,
              child: Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: widget.onCreatePost,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Text(
                    'What would you like to share?',
                    style: TextStyle(color: AppColors.muted),
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: widget.onCreatePost,
              icon: const Icon(
                Icons.image_outlined,
                color: AppColors.emerald,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyFeed() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.forum_outlined,
            size: 42,
            color: AppColors.emerald,
          ),
          SizedBox(height: 12),
          Text(
            'Your feed is waiting.',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Be the first to share something with the community.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// POST CARD
// ============================================================

class PostCard extends StatelessWidget {
  final PostItem post;
  final VoidCallback onLike;
  final VoidCallback onOpen;

  const PostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final liked = post.likes.contains('You');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: AppColors.emeraldDark,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.author,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${post.role} • ${post.location} • ${post.time}',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.more_horiz,
                  color: AppColors.muted,
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (post.content.isNotEmpty)
              Text(
                post.content,
                style: const TextStyle(height: 1.5),
              ),
            if (post.content.isNotEmpty)
              const SizedBox(height: 12),
            if (post.mediaPath != null)
              _postMedia(),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.emerald.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                post.category,
                style: const TextStyle(
                  color: Color(0xFF6ED6AC),
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Text(
                  '${post.likes.length} likes',
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Text(
                  '${post.comments.length} comments',
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const Divider(height: 22, color: AppColors.border),
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: onLike,
                    icon: Icon(
                      liked
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: liked
                          ? Colors.redAccent
                          : AppColors.muted,
                    ),
                    label: Text(
                      'Like',
                      style: TextStyle(
                        color: liked
                            ? Colors.redAccent
                            : AppColors.muted,
                        ),
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: onOpen,
                    icon: const Icon(
                      Icons.chat_bubble_outline,
                      color: AppColors.muted,
                    ),
                    label: const Text(
                      'Comment',
                      style: TextStyle(color: AppColors.muted),
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: onOpen,
                    icon: const Icon(
                      Icons.share_outlined,
                      color: AppColors.muted,
                    ),
                    label: const Text(
                      'Share',
                      style: TextStyle(color: AppColors.muted),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _postMedia() {
    final path = post.mediaPath!;

    if (post.mediaType == 'image') {
      final file = File(path);
      if (!file.existsSync()) {
        return _missingMedia();
      }

      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          file,
          width: double.infinity,
          height: 230,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _missingMedia(),
        ),
      );
    }

    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.play_circle_outline,
            color: AppColors.emerald,
            size: 52,
          ),
          SizedBox(height: 8),
          Text('Video attachment'),
          SizedBox(height: 4),
          Text(
            'Video playback is not implemented yet.',
            style: TextStyle(
              color: AppColors.muted,
              fontSize: 11,
              ),
          ),
        ],
      ),
    );
  }

  Widget _missingMedia() {
    return Container(
      height: 150,
      width: double.infinity,
      color: AppColors.surfaceLight,
      child: const Center(
        child: Text(
          'Media file is no longer available.',
          style: TextStyle(color: AppColors.muted),
        ),
      ),
    );
  }
}

// ============================================================
// CREATE POST
// ============================================================

class CreatePostSheet extends StatefulWidget {
  final UserProfile profile;
  final Function(PostItem) onPostCreated;

  const CreatePostSheet({
    super.key,
    required this.profile,
    required this.onPostCreated,
  });

  @override
  State<CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<CreatePostSheet> {
  final contentController = TextEditingController();
  final picker = ImagePicker();

  String category = 'General';
  XFile? selectedMedia;
  String mediaType = 'none';

  final categories = const [
    'General',
    'Mechanics & Tech',
    'Business & Trade',
  ];

  @override
  void dispose() {
    contentController.dispose();
    super.dispose();
  }

  Future<void> pickMedia(bool video) async {
    try {
      final file = video
          ? await picker.pickVideo(source: ImageSource.gallery)
          : await picker.pickImage(source: ImageSource.gallery);

      if (file == null) return;

      setState(() {
        selectedMedia = file;
        mediaType = video ? 'video' : 'image';
      });
    } catch (_) {
      if (mounted) {
        showMessage(context, 'Could not select that media file.');
      }
    }
  }

  void publishPost() {
    if (contentController.text.trim().isEmpty &&
        selectedMedia == null) {
      showMessage(context, 'Write something or select media first.');
      return;
    }

    final post = PostItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      author: widget.profile.name,
      role: widget.profile.role,
      location: widget.profile.location,
      category: category,
      content: contentController.text.trim(),
      mediaPath: selectedMedia?.path,
      mediaType: mediaType,
      time: 'Just now',
    );

    widget.onPostCreated(post);
    Navigator.pop(context);
    showMessage(context, 'Your post has been added.');
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 18,
        right: 18,
        top: 20,
        bottom: bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Create a post',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: contentController,
              minLines: 4,
              maxLines: 8,
              decoration: const InputDecoration(
                hintText: 'What would you like to share?',
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Choose a category',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: categories.map((item) {
                return ChoiceChip(
                  label: Text(item),
                  selected: category == item,
                  onSelected: (_) => setState(() => category = item),
                  selectedColor: AppColors.emerald,
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            if (selectedMedia != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      mediaType == 'image'
                          ? Icons.image
                          : Icons.video_file,
                      color: AppColors.emerald,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        selectedMedia!.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          selectedMedia = null;
                          mediaType = 'none';
                        });
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => pickMedia(false),
                  icon: const Icon(Icons.image_outlined),
                  label: const Text('Photo'),
                ),
                TextButton.icon(
                  onPressed: () => pickMedia(true),
                  icon: const Icon(Icons.video_library_outlined),
                  label: const Text('Video'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: publishPost,
                child: const Text('Publish post'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// POST DETAILS AND COMMENTS
// ============================================================

class PostDetailScreen extends StatefulWidget {
  final PostItem post;
  final Function(PostItem) onPostUpdated;

  const PostDetailScreen({
    super.key,
    required this.post,
    required this.onPostUpdated,
    });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late PostItem post;
  final commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    post = widget.post;
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  void addComment() {
    final text = commentController.text.trim();

    if (text.isEmpty) return;

    final updated = PostItem(
      id: post.id,
      author: post.author,
      role: post.role,
      location: post.location,
      category: post.category,
      content: post.content,
      mediaPath: post.mediaPath,
      mediaType: post.mediaType,
      time: post.time,
      likes: List<String>.from(post.likes),
      comments: [
        ...post.comments,
        CommentItem(
          author: 'You',
          text: text,
          time: 'Just now',
        ),
      ],
    );

    setState(() => post = updated);
    widget.onPostUpdated(updated);
    commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                PostCard(
                  post: post,
                  onLike: () {
                    final updated = PostItem(
                      id: post.id,
                      author: post.author,
                      role: post.role,
                      location: post.location,
                      category: post.category,
                      content: post.content,
                      mediaPath: post.mediaPath,
                      mediaType: post.mediaType,
                      time: post.time,
                      likes: List<String>.from(post.likes),
                      comments:
                      List<CommentItem>.from(post.comments),
                    );

                    if (updated.likes.contains('You')) {
                      updated.likes.remove('You');
                    } else {
                      updated.likes.add('You');
                    }

                    setState(() => post = updated);
                    widget.onPostUpdated(updated);
                  },
                  onOpen: () {},
                ),
                const SizedBox(height: 12),
                const Text(
                  'Comments',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                if (post.comments.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        'No comments yet. Start the conversation.',
                        style: TextStyle(color: AppColors.muted),
                      ),
                    ),
                  ),
                ...post.comments.map(
                  (comment) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          comment.author,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(comment.text),
                        const SizedBox(height: 5),
                        Text(
                          comment.time,
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: commentController,
                      decoration: const InputDecoration(
                        hintText: 'Write a comment...',
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: addComment,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// DISCOVER / RESOURCES
// ============================================================

class ResourceItem {
  final String title;
  final String description;
  final String category;
  final IconData icon;

  const ResourceItem({
    required this.title,
    required this.description,
    required this.category,
    required this.icon,
  });
}
class ResourcesHubScreen extends StatefulWidget {
  const ResourcesHubScreen({super.key});

  @override
  State<ResourcesHubScreen> createState() =>
      _ResourcesHubScreenState();
}

class _ResourcesHubScreenState extends State<ResourcesHubScreen> {
  final searchController = TextEditingController();
  String searchQuery = '';

  final resources = const [
    ResourceItem(
      title: 'Motorcycle maintenance',
      description:
          'Learn about engine servicing, troubleshooting and repairs.',
      category: 'Mechanics & Tech',
      icon: Icons.two_wheeler,
    ),
    ResourceItem(
      title: 'Electrical systems',
      description:
          'Explore motorcycle wiring, charging systems and diagnostics.',
      category: 'Mechanics & Tech',
      icon: Icons.electrical_services,
    ),
    ResourceItem(
      title: 'Business skills',
      description:
          'Ideas for starting, managing and growing a small business.',
      category: 'Business & Trade',
      icon: Icons.storefront_outlined,
    ),
    ResourceItem(
      title: 'Community opportunities',
      description:
          'A place to discover useful opportunities and share knowledge.',
      category: 'Community',
      icon: Icons.groups_outlined,
    ),
    ResourceItem(
      title: 'Learning and development',
      description:
          'Build practical skills and expand your knowledge.',
      category: 'Education',
      icon: Icons.school_outlined,
    ),
    ResourceItem(
      title: 'Transport information',
      description:
          'Explore transport-related information and useful guidance.',
      category: 'Transport',
      icon: Icons.directions_bus_outlined,
    ),
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = resources.where((item) {
      final query = searchQuery.toLowerCase();
      return item.title.toLowerCase().contains(query) ||
          item.description.toLowerCase().contains(query) ||
          item.category.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Discover',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Explore knowledge and opportunities.',
            style: TextStyle(
              color: AppColors.muted,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: searchController,
            onChanged: (value) {
              setState(() => searchQuery = value);
            },
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search resources...',
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Explore resources',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          if (filtered.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'No matching resources found.',
                  style: TextStyle(color: AppColors.muted),
                ),
              ),
            ),
          ...filtered.map(
            (item) => Card(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: AppColors.emerald.withValues(alpha: 0.13),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(
                        item.icon,
                        color: AppColors.emerald,
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.description,
                            style: const TextStyle(
                              color: AppColors.muted,
                              height: 1.4,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 9),
                          Text(
                            item.category,
                            style: const TextStyle(
                              color: Color(0xFF6ED6AC),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: AppColors.muted,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            'Resources shown here are starter content. '
            'External suppliers and opportunities have not been verified.',
            style: TextStyle(
              color: AppColors.muted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
// ============================================================
// DIRECT MESSAGES
// ============================================================

class DirectMessagesScreen extends StatelessWidget {
  const DirectMessagesScreen({super.key});

  final List<Map<String, String>> conversations = const [
    {
      'name': 'Community Support',
      'message': 'Welcome to Safe Space.',
      'time': '9:30 AM',
    },
    {
      'name': 'Mechanics Community',
      'message': 'Share your technical questions here.',
      'time': 'Yesterday',
    },
    {
      'name': 'Business Network',
      'message': 'Let us share business ideas.',
      'time': 'Monday',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Messages',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showMessage(
                context,
                'Messaging will be connected to the backend later.',
              );
            },
            icon: const Icon(Icons.edit_square),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Your conversations',
            style: TextStyle(
              color: AppColors.muted,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 15),
          ...conversations.map(
            (conversation) => ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 6),
              leading: const CircleAvatar(
                backgroundColor: AppColors.emeraldDark,
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: Text(
                conversation['name']!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                conversation['message']!,
                style: const TextStyle(color:
                                       AppColors.muted),
              ),
              trailing: Text(
                conversation['time']!,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 10,
                ),
              ),
              onTap: () {
                showMessage(
                  context,
                  'This is demo conversation data. Live messaging '
                  'is not connected yet.',
                );
              },
            ),
          ),
          const SizedBox(height: 25),
          const Center(
            child: Text(
              'Real conversations will appear here when messaging '
              'is connected.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.muted,
                 fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// NOTIFICATIONS
// ============================================================

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      {
        'title': 'Welcome to Safe Space',
        'message': 'Your community journey starts here.',
        'icon': Icons.waving_hand_outlined,
      },
      {
        'title': 'Discover',
        'message': 'Explore resources and learning opportunities.',
        'icon': Icons.explore_outlined,
      },
      {
        'title': 'Community',
        'message': 'Share your ideas with other members.',
        'icon': Icons.groups_outlined,
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: notifications.map((item) {
          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: CircleAvatar(
                backgroundColor:
                    AppColors.emerald.withValues(alpha: 0.15),
                child: Icon(
                  item['icon'] as IconData,
                  color: AppColors.emerald,
                ),
              ),
              title: Text(
                item['title'] as String,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                item['message'] as String,
                style: const TextStyle(color: AppColors.muted),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ============================================================
// PROFILE SCREEN
// ============================================================

class ProfileScreen extends StatelessWidget {
  final UserProfile profile;
  final Function(UserProfile) onProfileUpdated;
  final VoidCallback onLogout;

  const ProfileScreen({
    super.key,
    required this.profile,
    required this.onProfileUpdated,
    required this.onLogout,
  });

  Future<void> editProfile(BuildContext context) async {
    final nameController = TextEditingController(text: profile.name);
    final roleController = TextEditingController(text: profile.role);
    final locationController =
        TextEditingController(text: profile.location);
    final bioController = TextEditingController(text: profile.bio);

    final result = await showDialog<UserProfile>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Edit profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Display name',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: roleController,
                  decoration: const InputDecoration(
                    labelText: 'Profession or role',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bioController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'About you',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  UserProfile(
                    name: nameController.text.trim().isEmpty
                        ? profile.name
                        : nameController.text.trim(),
                    role: roleController.text.trim().isEmpty
                        ? profile.role
                        : roleController.text.trim(),
                    location:
                        locationController.text.trim().isEmpty
                            ? profile.location
                            : locationController.text.trim(),
                    bio: bioController.text.trim().isEmpty
                        ? profile.bio
                        : bioController.text.trim(),
                  ),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    nameController.dispose();
    roleController.dispose();
    locationController.dispose();
    bioController.dispose();

    if (result != null) {
      onProfileUpdated(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () => editProfile(context),
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit profile',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 43,
                  backgroundColor: AppColors.emeraldDark,
                  child: Icon(
                    Icons.person,
                    size: 46,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  profile.name,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  profile.role,
                  style: const TextStyle(color: AppColors.muted),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 15,
                      color: AppColors.muted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      profile.location,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  profile.bio,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.muted,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 18),
                OutlinedButton.icon(
                  onPressed: () => editProfile(context),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit profile'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Account',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
            ),
          const SizedBox(height: 10),
          _profileOption(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Notification preferences',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationsScreen(),
                ),
              );
            },
          ),
          _profileOption(
            icon: Icons.lock_outline,
            title: 'Privacy and security',
            subtitle: 'Account protection settings',
            onTap: () {
              showMessage(
                context,
                'Privacy settings will be added in a future update.',
              );
            },
          ),
          _profileOption(
            icon: Icons.info_outline,
            title: 'About Safe Space',
            subtitle: 'Born in Kenya. Built for the world.',
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Safe Space',
                applicationVersion: 'Prototype 1.0',
                applicationLegalese:
                    'A community platform prototype.',
              );
            },
          ),
          const SizedBox(height: 22),
          OutlinedButton.icon(
            onPressed: onLogout,
            icon: const Icon(
              Icons.logout,
              color: AppColors.danger,
            ),
            label: const Text(
              'Log out',
              style: TextStyle(color: AppColors.danger),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.border),
              padding: const EdgeInsets.all(14),
            ),
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'SAFE SPACE • PROTOTYPE',
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 10,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppColors.emerald),
        title: Text(title),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 12,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.muted,
        ),
      ),
    );
  }
}
// ============================================================
// SHARED HELPER
// ============================================================

void showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(message)),
    );
}


                
                
      
                      
        

              
