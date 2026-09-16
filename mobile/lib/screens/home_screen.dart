import 'package:flutter/material.dart';

import '../models/football_match.dart';
import '../services/matches_service.dart';
import '../widgets/match_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const MatchesService _matchesService = MatchesService();

  late Future<List<FootballMatch>> _matchesFuture;

  @override
  void initState() {
    super.initState();
    _matchesFuture = _matchesService.getFeaturedMatchesToday();
  }

  Future<void> _refresh() async {
    final future = _matchesService.getFeaturedMatchesToday();

    setState(() {
      _matchesFuture = future;
    });

    await future;
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
              'дДд Football',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'Резултати и мачове',
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
            return _ErrorView(
              message: snapshot.error.toString(),
              onRetry: _refresh,
            );
          }

          final matches = snapshot.data ?? [];

          if (matches.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                children: const [
                  SizedBox(height: 180),
                  Icon(Icons.sports_soccer, size: 54, color: Color(0xFF8492A6)),
                  SizedBox(height: 16),
                  Center(
                    child: Text(
                      'Няма мачове от избраните първенства днес.',
                      style: TextStyle(color: Color(0xFFAAB7C7)),
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
                    const Expanded(
                      child: Text(
                        'Важни мачове',
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
                for (final match in matches) MatchCard(match: match),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

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
            const Icon(Icons.cloud_off, size: 54, color: Color(0xFFFF6B6B)),
            const SizedBox(height: 16),
            const Text(
              'Неуспешно зареждане',
              style: TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFFAAB7C7)),
            ),
            const SizedBox(height: 20),
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
