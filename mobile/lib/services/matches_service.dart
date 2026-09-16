import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/api_config.dart';
import '../models/football_match.dart';

class MatchesService {
  const MatchesService();

  Future<List<FootballMatch>> getFeaturedMatchesToday() async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/matches/today?featured_only=true',
    );

    final response = await http.get(uri).timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('Backend error: HTTP ${response.statusCode}');
    }

    final decoded =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

    final matchesJson = decoded['matches'] as List<dynamic>? ?? <dynamic>[];

    return matchesJson
        .map((item) => FootballMatch.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
