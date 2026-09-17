import 'package:flutter/material.dart';

import '../models/football_match.dart';
import '../models/match_details.dart';
import '../services/matches_service.dart';

class MatchDetailsScreen extends StatefulWidget {
  const MatchDetailsScreen({required this.fixtureId, super.key});

  final int fixtureId;

  @override
  State<MatchDetailsScreen> createState() {
    return _MatchDetailsScreenState();
  }
}

class _MatchDetailsScreenState extends State<MatchDetailsScreen> {
  static const MatchesService _matchesService = MatchesService();

  late Future<MatchDetails> _detailsFuture;

  @override
  void initState() {
    super.initState();
    _detailsFuture = _loadDetails();
  }

  Future<MatchDetails> _loadDetails() {
    return _matchesService.getMatchDetails(widget.fixtureId);
  }

  Future<void> _refresh() async {
    final future = _loadDetails();

    setState(() {
      _detailsFuture = future;
    });

    await future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B111B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B111B),
        title: const Text(
          'Детайли за мача',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh)),
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder<MatchDetails>(
        future: _detailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF35D07F)),
            );
          }

          if (snapshot.hasError) {
            return _DetailsError(
              message: snapshot.error.toString(),
              onRetry: _refresh,
            );
          }

          final details = snapshot.data!;

          return RefreshIndicator(
            onRefresh: _refresh,
            color: const Color(0xFF35D07F),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 32),
              children: [
                _MatchHeader(details: details),
                const SizedBox(height: 22),
                const Text(
                  'Хронология',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                if (details.events.isEmpty)
                  const _NoEvents()
                else
                  for (final event in details.events) _EventTile(event: event),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MatchHeader extends StatelessWidget {
  const _MatchHeader({required this.details});

  final MatchDetails details;

  FootballMatch get match => details.match;

  String get score {
    if (match.homeGoals == null || match.awayGoals == null) {
      final hour = match.date.hour.toString().padLeft(2, '0');
      final minute = match.date.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }

    return '${match.homeGoals}  –  ${match.awayGoals}';
  }

  Widget _teamLogo(String? url) {
    if (url == null || url.isEmpty) {
      return const Icon(
        Icons.sports_soccer,
        size: 54,
        color: Color(0xFFAAB7C7),
      );
    }

    return Image.network(
      url,
      width: 64,
      height: 64,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) {
        return const Icon(
          Icons.sports_soccer,
          size: 54,
          color: Color(0xFFAAB7C7),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final venueParts = [
      details.venueName,
      details.venueCity,
    ].whereType<String>().where((value) => value.isNotEmpty).toList();

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF182232),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: match.isLive
              ? const Color(0xFF35D07F)
              : const Color(0xFF293548),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (match.leagueLogo != null)
                Image.network(
                  match.leagueLogo!,
                  width: 24,
                  height: 24,
                  errorBuilder: (_, __, ___) {
                    return const SizedBox.shrink();
                  },
                ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  match.leagueName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFAAB7C7),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    _teamLogo(match.homeTeamLogo),
                    const SizedBox(height: 12),
                    Text(
                      match.homeTeamName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 110,
                child: Column(
                  children: [
                    Text(
                      score,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      match.isLive && match.elapsed != null
                          ? "${match.elapsed}'"
                          : match.statusLong,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: match.isLive
                            ? const Color(0xFF35D07F)
                            : const Color(0xFF8492A6),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    _teamLogo(match.awayTeamLogo),
                    const SizedBox(height: 12),
                    Text(
                      match.awayTeamName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (venueParts.isNotEmpty) ...[
            const SizedBox(height: 22),
            const Divider(color: Color(0xFF293548)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.stadium_outlined,
                  size: 18,
                  color: Color(0xFF8492A6),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    venueParts.join(', '),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFFAAB7C7)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({required this.event});

  final MatchEvent event;

  IconData get icon {
    final type = event.type.toLowerCase();
    final detail = event.detail.toLowerCase();

    if (type == 'goal') {
      return Icons.sports_soccer;
    }

    if (type == 'card' && detail.contains('red')) {
      return Icons.style;
    }

    if (type == 'card') {
      return Icons.style;
    }

    if (type.contains('subst')) {
      return Icons.swap_horiz;
    }

    return Icons.circle;
  }

  Color get iconColor {
    final detail = event.detail.toLowerCase();

    if (detail.contains('red')) {
      return const Color(0xFFFF5B5B);
    }

    if (detail.contains('yellow')) {
      return const Color(0xFFFFD166);
    }

    if (event.type.toLowerCase() == 'goal') {
      return const Color(0xFF35D07F);
    }

    return const Color(0xFF8492A6);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF182232),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF293548)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Text(
              event.minute,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Icon(icon, color: iconColor, size: 21),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.playerName ?? event.detail,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  [
                    event.detail,
                    if (event.assistName != null)
                      'Асистенция: ${event.assistName}',
                    if (event.teamName != null) event.teamName!,
                  ].join(' • '),
                  style: const TextStyle(
                    color: Color(0xFF8492A6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NoEvents extends StatelessWidget {
  const _NoEvents();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF182232),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        children: [
          Icon(Icons.schedule, color: Color(0xFF8492A6), size: 38),
          SizedBox(height: 12),
          Text(
            'Все още няма събития за този мач.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFFAAB7C7)),
          ),
        ],
      ),
    );
  }
}

class _DetailsError extends StatelessWidget {
  const _DetailsError({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, color: Color(0xFFFF6B6B), size: 50),
            const SizedBox(height: 16),
            const Text(
              'Детайлите не могат да бъдат заредени.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFFAAB7C7)),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Опитай отново'),
            ),
          ],
        ),
      ),
    );
  }
}
