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
}

