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
),
likes(
  user_id
),
comments(
  id,
  content,
  created_at,
  profiles!comments_author_id_fkey(
    username,
    display_name
  )
)
        ''')
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  } catch (error) {
    throw Exception('Failed to fetch posts: $error');
  }
}
  Future<String> createPost({
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
    final response = await _client
    .from('posts')
    .insert({
      'author_id': user.id,
      'content': content,
      'category': category,
      'media_url': mediaUrl,
      'media_type': mediaType,
    })
    .select('id')
    .single();

return response['id'].toString();
  } catch (error) {
    throw Exception('Failed to publish post: $error');
  }
  }
  
  Future<void> likePost(String postId) async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception('You must be logged in to like posts.');
    }

    try {
      await _client.from('likes').insert({
        'post_id': postId,
        'user_id': user.id,
      });
    } catch (error) {
      throw Exception('Failed to like post: $error');
    }
  }

  Future<void> unlikePost(String postId) async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception('You must be logged in to unlike posts.');
    }

    try {
      await _client
          .from('likes')
          .delete()
          .eq('post_id', postId)
          .eq('user_id', user.id);
    } catch (error) {
      throw Exception('Failed to unlike post: $error');
    }
  }

  Future<void> createComment({
  required String postId,
  required String content,
}) async {
  final user = _client.auth.currentUser;

  if (user == null) {
    throw Exception('You must be logged in to comment.');
  }

  if (content.trim().isEmpty) {
    throw Exception('Comment cannot be empty.');
  }

  try {
    await _client.from('comments').insert({
      'post_id': postId,
      'author_id': user.id,
      'content': content.trim(),
    });
  } catch (error) {
    throw Exception('Failed to create comment: $error');
  }
  }
  
}

