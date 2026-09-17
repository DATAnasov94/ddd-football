import 'package:flutter/material.dart';

import '../models/football_match.dart';
import '../services/matches_service.dart';
import '../widgets/match_card.dart';
import 'match_details_screen.dart';

class LiveMatchesScreen extends StatefulWidget {
  const LiveMatchesScreen({super.key});

  @override
  State<LiveMatchesScreen> createState() {
    return _LiveMatchesScreenState();
  }
}

class _LiveMatchesScreenState extends State<LiveMatchesScreen> {
  static const MatchesService _matchesService = MatchesService();

  late Future<List<FootballMatch>> _matchesFuture;

  @override
  void initState() {
    super.initState();
    _matchesFuture = _matchesService.getLiveMatches();
  }

  Future<void> _refresh() async {
    final future = _matchesService.getLiveMatches();

    setState(() {
      _matchesFuture = future;
    });

    await future;
  }

  void _openMatch(FootballMatch match) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MatchDetailsScreen(fixtureId: match.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B111B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B111B),
        titleSpacing: 20,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'На живо',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'Текущи футболни срещи',
              style: TextStyle(color: Color(0xFF8492A6), fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
            tooltip: 'Обнови',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder<List<FootballMatch>>(
        future: _matchesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF35D07F)),
            );
          }

          if (snapshot.hasError) {
            return _LiveErrorView(
              message: snapshot.error.toString(),
              onRetry: _refresh,
            );
          }

          final matches = snapshot.data ?? [];

          if (matches.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              color: const Color(0xFF35D07F),
              child: ListView(
                padding: const EdgeInsets.all(30),
                children: const [
                  SizedBox(height: 130),
                  Icon(Icons.sports_soccer, size: 58, color: Color(0xFF8492A6)),
                  SizedBox(height: 18),
                  Center(
                    child: Text(
                      'В момента няма мачове на живо.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Издърпай надолу, за да провериш отново.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF8492A6)),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            color: const Color(0xFF35D07F),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 30),
              children: [
                Row(
                  children: [
                    Container(
                      width: 9,
                      height: 9,
                      decoration: const BoxDecoration(
                        color: Color(0xFF35D07F),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 9),
                    const Expanded(
                      child: Text(
                        'Играят се сега',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      '${matches.length} мача',
                      style: const TextStyle(color: Color(0xFF8492A6)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                for (final match in matches)
                  MatchCard(match: match, onTap: () => _openMatch(match)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LiveErrorView extends StatelessWidget {
  const _LiveErrorView({required this.message, required this.onRetry});

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
            const Icon(Icons.cloud_off, size: 52, color: Color(0xFFFF6B6B)),
            const SizedBox(height: 16),
            const Text(
              'Live мачовете не могат да бъдат заредени.',
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
