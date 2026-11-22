import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_service.dart';

class MediaStorageService {
  final SupabaseClient _client = SupabaseService.client;

  Future<String> uploadFile({
    required File file,
    required String folder,
    required String contentType,
  }) async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception('You must be logged in to upload media.');
    }

    if (folder != 'avatars' && folder != 'posts') {
      throw Exception('Invalid storage folder.');
    }

    try {
      final extension = file.path.split('.').last.toLowerCase();

      final fileName =
          '${DateTime.now().microsecondsSinceEpoch}.$extension';

      final filePath = '$folder/${user.id}/$fileName';

      await _client.storage
          .from('Avatars')
          .upload(
            filePath,
            file,
            fileOptions: FileOptions(
              contentType: contentType,
              upsert: false,
            ),
          );

      return _client.storage
          .from('Avatars')
          .getPublicUrl(filePath);
    } catch (error) {
      throw Exception('Media upload failed: $error');
    }
  }
}
