import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
}

class PostItem {
  final String author;
  final String category;
  final String time;
  final String content;
  int likes;
  bool isLiked;
  List<CommentItem> comments;

  PostItem({
    required this.author,
    required this.category,
    required this.time,
    required this.content,
    required this.likes,
    this.isLiked = false,
    List<CommentItem>? comments,
  }) : comments = comments ?? [];
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

  late final List<PostItem> _posts;

  @override
  void initState() {
    super.initState();
    _posts = [
      PostItem(
        author: 'Jonathan M.',
        category: 'Mechanics & Tech',
        time: '10m ago',
        content: 'Just completed a 150cc pushrod engine setup! Testing compression and smooth ignition timing today. Any tips on optimizing carburetor jetting for highland altitudes?',
        likes: 12,
        comments: [
          CommentItem(author: 'Peter K.', time: '5m ago', content: 'Try dropping the main jet size by one step to compensate for thinner air at higher altitudes!'),
        ],
      ),
      PostItem(
        author: 'Amina K.',
        category: 'Business & Trade',
        time: '1h ago',
        content: 'Looking for reliable spare parts suppliers for TVS HLX and Honda CB125 in the North Rift region. Drop recommendations below!',
        likes: 8,
        comments: [],
      ),
      PostItem(
        author: 'Safe Space Team',
        category: 'General',
        time: '3h ago',
        content: 'Karibu Safe Space Kenya! 🇰🇪 Connect with fellow mechanics, builders, and entrepreneurs across the country.',
        likes: 25,
        comments: [],
      ),
    ];
  }

  void _addPost(BuildContext sheetContext) {
    if (_newPostController.text.trim().isEmpty) return;

    setState(() {
      _posts.insert(
        0,
        PostItem(
          author: widget.userName.isEmpty ? 'Safe Space Member' : widget.userName,
          category: _selectedCategory == 'All' ? 'General' : _selectedCategory,
          time: 'Just now',
          content: _newPostController.text.trim(),
          likes: 0,
        ),
      );
    });

    _newPostController.clear();
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
  }

  void _openPostDetail(PostItem post) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PostDetailScreen(
          post: post,
          currentUser: widget.userName,
          onCommentAdded: () => setState(() {}),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredPosts = _selectedCategory == 'All'
        ? _posts
        : _posts.where((post) => post.category == _selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF004D40),
        title: const Text('Safe Space Community 🇰🇪', style: TextStyle(color: Colors.white)),
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
            child: ListView.builder(
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
                                  post.author[0],
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
                          const SizedBox(height: 12),
                          Text(
                            post.content,
                            style: const TextStyle(fontSize: 14, height: 1.4),
                          ),
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
                          widget.post.author[0],
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
                  const SizedBox(height: 16),
                  Text(
                    widget.post.content,
                    style: const TextStyle(fontSize: 16, height: 1.4),
                  ),
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
                                mainAxisAlignment: MainAxisAlignment.between,
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
            child: Row(
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

  ResourceItem({
    required this.title,
    required this.category,
    required this.contactInfo,
    required this.description,
  });
}

class ResourcesHubScreen extends StatelessWidget {
  const ResourcesHubScreen({super.key});

  final List<ResourceItem> _resources = const [
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF004D40),
        title: const Text('Trade & Supplier Hub 🇰🇪', style: TextStyle(color: Colors.white)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _resources.length,
        itemBuilder: (context, index) {
          final res = _resources[index];
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
                    mainAxisAlignment: MainAxisAlignment.between,
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
    );
  }
}

class ProfileScreen extends StatelessWidget {
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

  void _showEditProfileDialog(BuildContext context) {
    final nameController = TextEditingController(text: displayName);
    final roleController = TextEditingController(text: tradeRole);
    final locationController = TextEditingController(text: location);

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
                onProfileUpdated(
                  nameController.text.trim().isEmpty ? displayName : nameController.text.trim(),
                  roleController.text.trim().isEmpty ? tradeRole : roleController.text.trim(),
                  locationController.text.trim().isEmpty ? location : locationController.text.trim(),
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
    final displayPhone = phoneNumber.isEmpty ? '712345678' : phoneNumber;

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
                    displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$tradeRole • $location',
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
            ),
            const SizedBox(height: 16),
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
                          subtitle: Text('$displayName • $tradeRole'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _showEditProfileDialog(context),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.notifications_none, color: Color(0xFF004D40)),
                          title: const Text('Notifications'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {},
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
                                    
            
