import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/supabase_service.dart';

class FollowService {
  final SupabaseClient _client = SupabaseService.client;

  Future<void> followUser(String targetUserId) async {
  final currentUser = _client.auth.currentUser;

  if (currentUser == null) {
    throw Exception('You must be logged in to follow users.');
  }

  if (currentUser.id == targetUserId) {
    throw Exception('You cannot follow yourself.');
  }

  await _client.from('follows').insert({
    'follower_id': currentUser.id,
    'following_id': targetUserId,
  });
  }

  Future<void> unfollowUser(String targetUserId) async {
  final currentUser = _client.auth.currentUser;

  if (currentUser == null) {
    throw Exception('You must be logged in to unfollow users.');
  }

  await _client
      .from('follows')
      .delete()
      .eq('follower_id', currentUser.id)
      .eq('following_id', targetUserId);
  }

  Future<bool> isFollowing(String targetUserId) async {
  final currentUser = _client.auth.currentUser;

  if (currentUser == null) {
    return false;
  }

  final result = await _client
      .from('follows')
      .select('id')
      .eq('follower_id', currentUser.id)
      .eq('following_id', targetUserId)
      .maybeSingle();

  return result != null;
  }

  Future<int> getFollowersCount(String userId) async {
  final result = await _client
      .from('follows')
      .select('id')
      .eq('following_id', userId);

  return result.length;
  }

  Future<int> getFollowingCount(String userId) async {
  final result = await _client
      .from('follows')
      .select('id')
      .eq('follower_id', userId);

  return result.length;
  }
}


