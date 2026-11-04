import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const SafeSpaceApp());
}

class SafeSpaceApp extends StatelessWidget {
  const SafeSpaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Safe Space Kenya',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF004D40),
          primary: const Color(0xFF004D40),
        ),
      ),
      home: const PhoneAuthScreen(),
    );
  }
}

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  
  bool _codeSent = false;
  bool _isLoading = false;

  void _sendOTP() async {
    if (_phoneController.text.trim().isEmpty) return;
    
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _isLoading = false;
      _codeSent = true;
    });
  }

  void _verifyOTP() async {
    if (_otpController.text.trim().isEmpty) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);

    if (_otpController.text.trim() == "123456") {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => MainNavigationContainer(phoneNumber: _phoneController.text),
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid OTP! Try using 123456')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF004D40),
        title: const Text('Safe Space 🇰🇪', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _codeSent ? 'Enter Verification Code' : 'Welcome to Safe Space',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF004D40),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _codeSent
                  ? 'We sent a 6-digit code to +254 ${_phoneController.text}'
                  : 'Enter your phone number to get started',
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (!_codeSent) ...[
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixText: '+254 ',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _sendOTP,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF004D40),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Send Verification Code'),
              ),
            ] else ...[
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(letterSpacing: 8, fontSize: 20),
                decoration: const InputDecoration(
                  labelText: '6-Digit Code',
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _verifyOTP,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF004D40),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Verify & Login'),
              ),
              TextButton(
                onPressed: () => setState(() => _codeSent = false),
                child: const Text('Change Phone Number'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class MainNavigationContainer extends StatefulWidget {
  final String phoneNumber;
  const MainNavigationContainer({super.key, required this.phoneNumber});

  @override
  State<MainNavigationContainer> createState() => _MainNavigationContainerState();
}

class _MainNavigationContainerState extends State<MainNavigationContainer> {
  int _currentIndex = 0;
  String _displayName = "Safe Space Member";
  String _tradeRole = "Motorcycle Specialist";
  String _location = "Kenya";
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _displayName = prefs.getString('display_name') ?? "Safe Space Member";
      _tradeRole = prefs.getString('trade_role') ?? "Motorcycle Specialist";
      _location = prefs.getString('location') ?? "Kenya";
      _isLoadingProfile = false;
    });
  }

  Future<void> _updateProfile(String newName, String newRole, String newLocation) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('display_name', newName);
    await prefs.setString('trade_role', newRole);
    await prefs.setString('location', newLocation);

    setState(() {
      _displayName = newName;
      _tradeRole = newRole;
      _location = newLocation;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingProfile) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFF004D40))),
      );
    }

    final screens = [
      HomeScreen(phoneNumber: widget.phoneNumber, userName: _displayName),
      const ResourcesHubScreen(),
      const DirectMessagesScreen(),
      ProfileScreen(
        phoneNumber: widget.phoneNumber,
        displayName: _displayName,
        tradeRole: _tradeRole,
        location: _location,
        onProfileUpdated: _updateProfile,
      ),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF004D40),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_shared_outlined),
            activeIcon: Icon(Icons.folder_shared),
            label: 'Resources',
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

class CommentItem {
  final String author;
  final String time;
  final String content;

  CommentItem({
    required this.author,
    required this.time,
    required this.content,
  });

  Map<String, dynamic> toJson() => {
        'author': author,
        'time': time,
        'content': content,
      };

  factory CommentItem.fromJson(Map<String, dynamic> json) {
    return CommentItem(
      author: json['author'] ?? '',
      time: json['time'] ?? '',
      content: json['content'] ?? '',
    );
  }
}

class PostItem {
  final String author;
  final String category;
  final String time;
  final String content;
  final File? mediaFile;
  final bool isVideo;
  int likes;
  bool isLiked;
  List<CommentItem> comments;

  PostItem({
    required this.author,
    required this.category,
    required this.time,
    required this.content,
    this.mediaFile,
    this.isVideo = false,
    required this.likes,
    this.isLiked = false,
    List<CommentItem>? comments,
  }) : comments = comments ?? [];

  Map<String, dynamic> toJson() => {
        'author': author,
        'category': category,
        'time': time,
        'content': content,
        'mediaPath': mediaFile?.path,
        'isVideo': isVideo,
        'likes': likes,
        'isLiked': isLiked,
        'comments': comments.map((c) => c.toJson()).toList(),
      };

  factory PostItem.fromJson(Map<String, dynamic> json) {
    return PostItem(
      author: json['author'] ?? '',
      category: json['category'] ?? 'General',
      time: json['time'] ?? '',
      content: json['content'] ?? '',
      mediaFile: json['mediaPath'] != null ? File(json['mediaPath']) : null,
      isVideo: json['isVideo'] ?? false,
      likes: json['likes'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      comments: (json['comments'] as List<dynamic>? ?? [])
          .map((c) => CommentItem.fromJson(c))
          .toList(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final String phoneNumber;
  final String userName;
  const HomeScreen({super.key, required this.phoneNumber, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'All';
  final TextEditingController _newPostController = TextEditingController();
  File? _selectedMediaFile;
  bool _isMediaTypeVideo = false;
  final ImagePicker _picker = ImagePicker();

  List<PostItem> _posts = [];
  bool _isLoadingPosts = true;

  final List<String> _quickEmojis = ['🔧', '⚙️', '🏍️', '🔥', '🇰🇪', '💯', '👍', '👏'];

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final String? postsJsonString = prefs.getString('saved_community_posts');

    if (postsJsonString != null) {
      try {
        final List<dynamic> decodedList = jsonDecode(postsJsonString);
        setState(() {
          _posts = decodedList.map((item) => PostItem.fromJson(item)).toList();
          _isLoadingPosts = false;
        });
        return;
      } catch (_) {}
    }

    setState(() {
      _posts = [
        PostItem(
          author: 'Jonathan M.',
          category: 'Mechanics & Tech',
          time: '10m ago',
          content: 'Just completed a 150cc pushrod engine setup! 🔧 Testing compression and smooth ignition timing today. Any tips on carburetor jetting? ⚙️',
          likes: 12,
          comments: [
            CommentItem(author: 'Peter K.', time: '5m ago', content: 'Try dropping the main jet size by one step for high altitudes! 👍'),
          ],
        ),
        PostItem(
          author: 'Amina K.',
          category: 'Business & Trade',
          time: '1h ago',
          content: 'Looking for reliable spare parts suppliers for TVS HLX and Honda CB125 in North Rift. Drop recommendations! 🇰🇪',
          likes: 8,
          comments: [],
        ),
      ];
      _isLoadingPosts = false;
    });
    _savePosts();
  }

  Future<void> _savePosts() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(_posts.map((p) => p.toJson()).toList());
    await prefs.setString('saved_community_posts', encodedData);
  }

  Future<void> _pickMedia(bool isVideo) async {
    final XFile? pickedFile = isVideo
        ? await _picker.pickVideo(source: ImageSource.gallery)
        : await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (pickedFile != null) {
      setState(() {
        _selectedMediaFile = File(pickedFile.path);
        _isMediaTypeVideo = isVideo;
      });
    }
  }

  void _addPost(BuildContext sheetContext) {
    if (_newPostController.text.trim().isEmpty && _selectedMediaFile == null) return;

    setState(() {
      _posts.insert(
        0,
        PostItem(
          author: widget.userName.isEmpty ? 'Safe Space Member' : widget.userName,
          category: _selectedCategory == 'All' ? 'General' : _selectedCategory,
          time: 'Just now',
          content: _newPostController.text.trim(),
          mediaFile: _selectedMediaFile,
          isVideo: _isMediaTypeVideo,
          likes: 0,
        ),
      );
    });

    _savePosts();
    _newPostController.clear();
    _selectedMediaFile = null;
    _isMediaTypeVideo = false;
    Navigator.pop(sheetContext);
  }

  void _showCreatePostSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
                left: 16,
                right: 16,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Create a Post',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF004D40)),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _newPostController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: "What's on your mind? Share an update or question...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _quickEmojis.map((emoji) {
                        return InkWell(
                          onTap: () {
                            _newPostController.text += emoji;
                            setModalState(() {});
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                            child: Text(emoji, style: const TextStyle(fontSize: 22)),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () async {
                          await _pickMedia(false);
                          setModalState(() {});
                        },
                        icon: const Icon(Icons.image, color: Color(0xFF004D40)),
                        label: const Text('Image', style: TextStyle(color: Color(0xFF004D40))),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: () async {
                          await _pickMedia(true);
                          setModalState(() {});
                        },
                        icon: const Icon(Icons.videocam, color: Color(0xFF004D40)),
                        label: const Text('Video', style: TextStyle(color: Color(0xFF004D40))),
                      ),
                    ],
                  ),
                  if (_selectedMediaFile != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _isMediaTypeVideo ? Icons.video_file : Icons.image,
                                color: const Color(0xFF004D40),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isMediaTypeVideo ? 'Video attached' : 'Image attached',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF004D40)),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () {
                              setModalState(() {
                                _selectedMediaFile = null;
                                _isMediaTypeVideo = false;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _addPost(sheetContext),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF004D40),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Post to Community'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openPostDetail(PostItem post) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PostDetailScreen(
          post: post,
          currentUser: widget.userName,
          onCommentAdded: () {
            setState(() {});
            _savePosts();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingPosts) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFF004D40))),
      );
    }

    final filteredPosts = _selectedCategory == 'All'
        ? _posts
        : _posts.where((post) => post.category == _selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF004D40),
        title: const Text('Safe Space Community 🇰🇪', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreatePostSheet,
        backgroundColor: const Color(0xFF004D40),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_comment),
        label: const Text('New Post'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            color: Colors.grey.shade100,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Mechanics & Tech', 'Business & Trade', 'General'].map((category) {
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: isSelected,
                      selectedColor: const Color(0xFF004D40),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedCategory = category);
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: filteredPosts.isEmpty
                ? const Center(
                    child: Text(
                      'No posts in this category yet. Be the first to share!',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredPosts.length,
                    itemBuilder: (context, index) {
                      final post = filteredPosts[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 1.5,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => _openPostDetail(post),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: const Color(0xFF004D40),
                                      radius: 18,
                                      child: Text(
                                        post.author.isNotEmpty ? post.author[0] : 'S',
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            post.author,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                          ),
                                          Text(
                                            '${post.category} • ${post.time}',
                                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                if (post.content.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Text(
                                    post.content,
                                    style: const TextStyle(fontSize: 14, height: 1.4),
                                  ),
                                ],
                                if (post.mediaFile != null && post.mediaFile!.existsSync()) ...[
                                  const SizedBox(height: 12),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: post.isVideo
                                        ? Container(
                                            height: 180,
                                            width: double.infinity,
                                            color: Colors.black87,
                                            child: const Center(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.play_circle_fill, size: 50, color: Colors.white),
                                                  SizedBox(height: 8),
                                                  Text('Attached Video', style: TextStyle(color: Colors.white, fontSize: 12)),
                                                ],
                                              ),
                                            ),
                                          )
                                        : Image.file(
                                            post.mediaFile!,
                                            height: 200,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                ],
                                const SizedBox(height: 12),
                                const Divider(height: 1),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          post.isLiked = !post.isLiked;
                                          post.likes += post.isLiked ? 1 : -1;
                                        });
                                        _savePosts();
                                      },
                                      child: Row(
                                        children: [
                                          Icon(
                                            post.isLiked ? Icons.favorite : Icons.favorite_border,
                                            color: post.isLiked ? Colors.red : Colors.grey,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${post.likes}',
                                            style: TextStyle(
                                              color: post.isLiked ? Colors.red : Colors.grey.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 24),
                                    InkWell(
                                      onTap: () => _openPostDetail(post),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.chat_bubble_outline, color: Colors.grey, size: 20),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${post.comments.length} ${post.comments.length == 1 ? 'Reply' : 'Replies'}',
                                            style: const TextStyle(color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class PostDetailScreen extends StatefulWidget {
  final PostItem post;
  final String currentUser;
  final VoidCallback onCommentAdded;

  const PostDetailScreen({
    super.key,
    required this.post,
    required this.currentUser,
    required this.onCommentAdded,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  final List<String> _quickEmojis = ['👍', '🔥', '🔧', '👏', '💡', '🇰🇪'];

  void _submitComment() {
    if (_commentController.text.trim().isEmpty) return;

    setState(() {
      widget.post.comments.add(
        CommentItem(
          author: widget.currentUser,
          time: 'Just now',
          content: _commentController.text.trim(),
        ),
      );
    });

    widget.onCommentAdded();
    _commentController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF004D40),
        foregroundColor: Colors.white,
        title: const Text('Post Discussion'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color(0xFF004D40),
                        radius: 20,
                        child: Text(
                          widget.post.author.isNotEmpty ? widget.post.author[0] : 'S',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.post.author,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            '${widget.post.category} • ${widget.post.time}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (widget.post.content.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      widget.post.content,
                      style: const TextStyle(fontSize: 16, height: 1.4),
                    ),
                  ],
                  if (widget.post.mediaFile != null && widget.post.mediaFile!.existsSync()) ...[
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: widget.post.isVideo
                          ? Container(
                              height: 200,
                              width: double.infinity,
                              color: Colors.black87,
                              child: const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.play_circle_fill, size: 60, color: Colors.white),
                                    SizedBox(height: 8),
                                    Text('Attached Video Preview', style: TextStyle(color: Colors.white)),
                                  ],
                                ),
                              ),
                            )
                          : Image.file(
                              widget.post.mediaFile!,
                              height: 240,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'Replies (${widget.post.comments.length})',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF004D40),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (widget.post.comments.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      child: Center(
                        child: Text(
                          'No replies yet. Be the first to share your thoughts!',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.post.comments.length,
                      itemBuilder: (context, index) {
                        final comment = widget.post.comments[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    comment.author,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                  Text(
                                    comment.time,
                                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                comment.content,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, -2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: _quickEmojis.map((emoji) {
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _commentController.text += emoji;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12.0, bottom: 6.0),
                        child: Text(emoji, style: const TextStyle(fontSize: 20)),
                      ),
                    );
                  }).toList(),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: const InputDecoration(
                          hintText: 'Write a reply...',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _submitComment,
                      icon: const Icon(Icons.send, color: Color(0xFF004D40)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ResourceItem {
  final String title;
  final String category;
  final String contactInfo;
  final String description;

  const ResourceItem({
    required this.title,
    required this.category,
    required this.contactInfo,
    required this.description,
  });
}

class ResourcesHubScreen extends StatefulWidget {
  const ResourcesHubScreen({super.key});

  @override
  State<ResourcesHubScreen> createState() => _ResourcesHubScreenState();
}

class _ResourcesHubScreenState extends State<ResourcesHubScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  static const List<ResourceItem> _allResources = [
    ResourceItem(
      title: 'North Rift Spares & Hardware',
      category: 'Spare Parts',
      contactInfo: 'Eldoret • 0712 345 678',
      description: 'Specializes in wholesale TVS HLX, Honda Ace CB125, and CG150 pushrod engine components.',
    ),
    ResourceItem(
      title: 'Koinange St. Mechanics Supply',
      category: 'Tools & Equipment',
      contactInfo: 'Nairobi • 0722 987 654',
      description: 'Reliable source for precision gauges, carburetor jet kits, and heavy-duty shop tools.',
    ),
    ResourceItem(
      title: 'NTSA Vehicle Registration Guide',
      category: 'Compliance & Legal',
      contactInfo: 'TIMS Portal Online',
      description: 'Step-by-step documentation checklist for inspecting and registering custom-built or modified motorcycles.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filteredResources = _allResources.where((res) {
      final query = _searchQuery.toLowerCase();
      return res.title.toLowerCase().contains(query) ||
          res.category.toLowerCase().contains(query) ||
          res.description.toLowerCase().contains(query) ||
          res.contactInfo.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF004D40),
        title: const Text('Trade & Supplier Hub 🇰🇪', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
              decoration: InputDecoration(
                hintText: 'Search suppliers, parts, or towns...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF004D40)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          Expanded(
            child: filteredResources.isEmpty
                ? const Center(
                    child: Text('No matching suppliers found.', style: TextStyle(color: Colors.grey)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: filteredResources.length,
                    itemBuilder: (context, index) {
                      final res = filteredResources[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 1.5,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      res.title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF004D40),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.teal.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.teal.shade200),
                                    ),
                                    child: Text(
                                      res.category,
                                      style: TextStyle(fontSize: 11, color: Colors.teal.shade800, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                res.description,
                                style: const TextStyle(fontSize: 14, color: Colors.black87),
                              ),
                              const SizedBox(height: 12),
                              const Divider(height: 1),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.phone_outlined, size: 16, color: Colors.grey),
                                  const SizedBox(width: 6),
                                  Text(
                                    res.contactInfo,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class DirectMessagesScreen extends StatelessWidget {
  const DirectMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chats = [
      {'name': 'Peter K.', 'message': 'Hey brother, do you have extra carburetor jet needles?', 'time': '12m ago'},
      {'name': 'Amina K.', 'message': 'Thanks for the supplier contact info!', 'time': '2h ago'},
      {'name': 'Safe Space Support', 'message': 'Karibu! Let us know if you need any app assistance.', 'time': '1d ago'},
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF004D40),
        title: const Text('Direct Messages', style: TextStyle(color: Colors.white)),
      ),
      body: ListView.separated(
        itemCount: chats.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final chat = chats[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF004D40),
              child: Text(chat['name']![0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            title: Text(chat['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(chat['message']!, maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: Text(chat['time']!, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Opening chat with ${chat['name']}...')),
              );
            },
          );
        },
      ),
    );
  }
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final alerts = [
      {'title': 'New Reply on Post', 'body': 'Peter K. commented on your pushrod engine setup post.', 'time': '5m ago'},
      {'title': 'New Resource Added', 'body': 'North Rift Spares updated their catalog listing.', 'time': '1h ago'},
      {'title': 'System Update', 'body': 'Safe Space Kenya version 1.0.0+1 is now live!', 'time': '1d ago'},
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF004D40),
        foregroundColor: Colors.white,
        title: const Text('Notifications'),
      ),
      body: ListView.separated(
        itemCount: alerts.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final alert = alerts[index];
          return ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFF00695C),
              child: Icon(Icons.notifications, color: Colors.white, size: 20),
            ),
            title: Text(alert['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(alert['body']!),
            trailing: Text(alert['time']!, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          );
        },
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  final String phoneNumber;
  final String displayName;
  final String tradeRole;
  final String location;
  final Function(String name, String role, String loc) onProfileUpdated;

  const ProfileScreen({
    super.key,
    required this.phoneNumber,
    required this.displayName,
    required this.tradeRole,
    required this.location,
    required this.onProfileUpdated,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationPref();
  }

  Future<void> _loadNotificationPref() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    setState(() => _notificationsEnabled = value);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(value ? 'Community alerts enabled!' : 'Community alerts muted.'),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final nameController = TextEditingController(text: widget.displayName);
    final roleController = TextEditingController(text: widget.tradeRole);
    final locationController = TextEditingController(text: widget.location);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Account Info', style: TextStyle(color: Color(0xFF004D40))),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name / Display Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: roleController,
                  decoration: const InputDecoration(
                    labelText: 'Trade / Role (e.g. Mechanic, Trader)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'County / Location',
                    border: OutlineInputBorder(),
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
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF004D40),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                widget.onProfileUpdated(
                  nameController.text.trim().isEmpty ? widget.displayName : nameController.text.trim(),
                  roleController.text.trim().isEmpty ? widget.tradeRole : roleController.text.trim(),
                  locationController.text.trim().isEmpty ? widget.location : locationController.text.trim(),
                );
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile saved locally!')),
                );
              },
              child: const Text('Save Changes'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayPhone = widget.phoneNumber.isEmpty ? '712345678' : widget.phoneNumber;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF004D40),
        title: const Text('My Profile & Settings', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: const Color(0xFF004D40),
              padding: const EdgeInsets.only(bottom: 24.0, left: 16.0, right: 16.0),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 42,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 39,
                      backgroundColor: Color(0xFF00695C),
                      child: Icon(Icons.person, size: 48, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.tradeRole} • ${widget.location}',
                    style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '+254 $displayPhone',
                    style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade700,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified, size: 16, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'Verified Member',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
                    child: Text(
                      'ACCOUNT SETTINGS',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 1,
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.person_outline, color: Color(0xFF004D40)),
                          title: const Text('Edit Account Info'),
                          subtitle: Text('${widget.displayName} • ${widget.tradeRole}'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _showEditProfileDialog(context),
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          secondary: const Icon(Icons.notifications_none, color: Color(0xFF004D40)),
                          title: const Text('Push Notifications'),
                          subtitle: const Text('Receive community alerts & replies'),
                          value: _notificationsEnabled,
                          activeColor: const Color(0xFF004D40),
                          onChanged: _toggleNotifications,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red.shade700,
                        side: BorderSide(color: Colors.red.shade300),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const PhoneAuthScreen()),
                        );
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
