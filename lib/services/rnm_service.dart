import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/character.dart';
import '../models/paged_response.dart';

class RnmService {
  static const String baseUrl = 'https://rickandmortyapi.com/api';
  final http.Client _client;

  RnmService({http.Client? client}) : _client = client ?? http.Client();

  Future<PagedResponse<Character>> fetchCharacters({
    int page = 1,
    String? name,
  }) async {
    // Build URL with optional query
    final uri = Uri.parse('$baseUrl/character').replace(
      queryParameters: {
        'page': page.toString(),
        if (name != null && name.isNotEmpty) 'name': name,
      },
    );

    final response = await _client.get(uri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final info = data['info'] as Map<String, dynamic>;
      final List<dynamic> results = data['results'] as List<dynamic>;

      final characters = results
          .map((e) => Character.fromJson(e as Map<String, dynamic>))
          .toList();

      return PagedResponse<Character>(
        count: info['count'] as int?,
        pages: info['pages'] as int?,
        next: info['next'] as String?,
        prev: info['prev'] as String?,
        results: characters,
      );
    }

    if (response.statusCode == 404) {
      // RM API returns 404 for empty search; treat as empty page
      return PagedResponse<Character>(
        count: 0,
        pages: 0,
        next: null,
        prev: null,
        results: [],
      );
    }

    throw Exception('Failed to load characters: {response.statusCode}');
  }
}
