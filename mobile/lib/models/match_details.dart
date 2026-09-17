import 'football_match.dart';

class MatchDetails {
  const MatchDetails({
    required this.match,
    required this.venueName,
    required this.venueCity,
    required this.events,
  });

  final FootballMatch match;
  final String? venueName;
  final String? venueCity;
  final List<MatchEvent> events;

  factory MatchDetails.fromJson(Map<String, dynamic> json) {
    final venue = json['venue'] as Map<String, dynamic>? ?? <String, dynamic>{};

    final eventsJson = json['events'] as List<dynamic>? ?? <dynamic>[];

    return MatchDetails(
      match: FootballMatch.fromJson(json),
      venueName: venue['name'] as String?,
      venueCity: venue['city'] as String?,
      events: eventsJson
          .map((event) => MatchEvent.fromJson(event as Map<String, dynamic>))
          .toList(),
    );
  }
}

class MatchEvent {
  const MatchEvent({
    required this.elapsed,
    required this.extra,
    required this.teamId,
    required this.teamName,
    required this.playerName,
    required this.assistName,
    required this.type,
    required this.detail,
  });

  final int? elapsed;
  final int? extra;
  final int? teamId;
  final String? teamName;
  final String? playerName;
  final String? assistName;
  final String type;
  final String detail;

  String get minute {
    if (elapsed == null) {
      return '–';
    }

    if (extra != null && extra! > 0) {
      return "$elapsed+$extra'";
    }

    return "$elapsed'";
  }

  factory MatchEvent.fromJson(Map<String, dynamic> json) {
    final time = json['time'] as Map<String, dynamic>? ?? <String, dynamic>{};

    final team = json['team'] as Map<String, dynamic>? ?? <String, dynamic>{};

    final player =
        json['player'] as Map<String, dynamic>? ?? <String, dynamic>{};

    final assist =
        json['assist'] as Map<String, dynamic>? ?? <String, dynamic>{};

    return MatchEvent(
      elapsed: time['elapsed'] as int?,
      extra: time['extra'] as int?,
      teamId: team['id'] as int?,
      teamName: team['name'] as String?,
      playerName: player['name'] as String?,
      assistName: assist['name'] as String?,
      type: json['type'] as String? ?? 'Event',
      detail: json['detail'] as String? ?? '',
    );
  }
}
