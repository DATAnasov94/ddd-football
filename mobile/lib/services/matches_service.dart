import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/api_config.dart';
import '../models/football_match.dart';
import '../models/match_details.dart';

class MatchesService {
  const MatchesService();

  Future<List<FootballMatch>> getFeaturedMatchesToday() {
    return getFeaturedMatchesByDate(DateTime.now());
  }

  Future<List<FootballMatch>> getFeaturedMatchesByDate(DateTime date) async {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final formattedDate = '$year-$month-$day';

    final uri = Uri.parse('${ApiConfig.baseUrl}/api/matches').replace(
      queryParameters: {'match_date': formattedDate, 'featured_only': 'true'},
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

  Future<MatchDetails> getMatchDetails(int fixtureId) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/matches/$fixtureId');

    final response = await http.get(uri).timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('Backend error: HTTP ${response.statusCode}');
    }

    final decoded =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

    return MatchDetails.fromJson(decoded);
  }

  Future<List<FootballMatch>> getLiveMatches() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/matches/live');

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
