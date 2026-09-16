class FootballMatch {
  const FootballMatch({
    required this.id,
    required this.date,
    required this.statusLong,
    required this.statusShort,
    required this.elapsed,
    required this.leagueId,
    required this.leagueName,
    required this.leagueLogo,
    required this.homeTeamName,
    required this.homeTeamLogo,
    required this.awayTeamName,
    required this.awayTeamLogo,
    required this.homeGoals,
    required this.awayGoals,
  });

  final int id;
  final DateTime date;
  final String statusLong;
  final String statusShort;
  final int? elapsed;

  final int leagueId;
  final String leagueName;
  final String? leagueLogo;

  final String homeTeamName;
  final String? homeTeamLogo;

  final String awayTeamName;
  final String? awayTeamLogo;

  final int? homeGoals;
  final int? awayGoals;

  bool get isLive {
    const liveStatuses = {
      '1H',
      'HT',
      '2H',
      'ET',
      'BT',
      'P',
      'SUSP',
      'INT',
      'LIVE',
    };

    return liveStatuses.contains(statusShort);
  }

  factory FootballMatch.fromJson(Map<String, dynamic> json) {
    final status =
        json['status'] as Map<String, dynamic>? ?? <String, dynamic>{};

    final league =
        json['league'] as Map<String, dynamic>? ?? <String, dynamic>{};

    final homeTeam =
        json['home_team'] as Map<String, dynamic>? ?? <String, dynamic>{};

    final awayTeam =
        json['away_team'] as Map<String, dynamic>? ?? <String, dynamic>{};

    final goals = json['goals'] as Map<String, dynamic>? ?? <String, dynamic>{};

    return FootballMatch(
      id: json['id'] as int,
      date: DateTime.parse(json['date'] as String).toLocal(),
      statusLong: status['long'] as String? ?? 'Unknown',
      statusShort: status['short'] as String? ?? 'NS',
      elapsed: status['elapsed'] as int?,
      leagueId: league['id'] as int,
      leagueName: league['name'] as String? ?? 'Unknown league',
      leagueLogo: league['logo'] as String?,
      homeTeamName: homeTeam['name'] as String? ?? 'Home team',
      homeTeamLogo: homeTeam['logo'] as String?,
      awayTeamName: awayTeam['name'] as String? ?? 'Away team',
      awayTeamLogo: awayTeam['logo'] as String?,
      homeGoals: goals['home'] as int?,
      awayGoals: goals['away'] as int?,
    );
  }
}
