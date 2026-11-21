import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/supabase_service.dart';

class PostService {
  final SupabaseClient _client = SupabaseService.client;

Future<List<Map<String, dynamic>>> fetchPosts() async {
  try {
    final response = await _client
        .from('posts')
        .select('''
          id,
          author_id,
          content,
          media_url,
          media_type,
          category,
          created_at,
          profiles!posts_author_id_fkey(
          username,
            display_name
          )
        ''')
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  } catch (error) {
    throw Exception('Failed to fetch posts: $error');
  }
}
  Future<void> createPost({
  required String content,
  required String category,
  String? mediaUrl,
  String? mediaType,
}) async {
  final user = _client.auth.currentUser;

  if (user == null) {
    throw Exception('You must be logged in to publish a post.');
  }

  try {
    await _client.from('posts').insert({
      'author_id': user.id,
      'content': content,
      'category': category,
      'media_url': mediaUrl,
      'media_type': mediaType,
    });
  } catch (error) {
    throw Exception('Failed to publish post: $error');
  }
  }
}

