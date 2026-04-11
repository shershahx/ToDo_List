import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/post.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class ApiService {
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';

  /// Fetches all users from the JSONPlaceholder API.
  Future<List<User>> fetchUsers() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/users'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => User.fromJson(json)).toList();
      } else {
        throw ApiException(
          'Failed to load users (status ${response.statusCode})',
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Network error: Could not reach the server.');
    }
  }

  /// Fetches all posts for a given [userId] from the JSONPlaceholder API.
  Future<List<Post>> fetchUserPosts(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/users/$userId/posts'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Post.fromJson(json)).toList();
      } else {
        throw ApiException(
          'Failed to load posts (status ${response.statusCode})',
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Network error: Could not reach the server.');
    }
  }
}
