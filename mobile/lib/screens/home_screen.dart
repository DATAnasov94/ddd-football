import 'package:flutter/material.dart';

import '../models/football_match.dart';
import '../services/matches_service.dart';
import '../widgets/match_card.dart';
import 'match_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const MatchesService _matchesService = MatchesService();

  late DateTime _selectedDate;
  late Future<List<FootballMatch>> _matchesFuture;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    _selectedDate = DateTime(now.year, now.month, now.day);

    _matchesFuture = _loadSelectedDate();
  }

  Future<List<FootballMatch>> _loadSelectedDate() {
    return _matchesService.getFeaturedMatchesByDate(_selectedDate);
  }

  Future<void> _refresh() async {
    final future = _loadSelectedDate();

    setState(() {
      _matchesFuture = future;
    });

    await future;
  }

  void _selectDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);

    if (_isSameDate(normalizedDate, _selectedDate)) {
      return;
    }

    setState(() {
      _selectedDate = normalizedDate;
      _matchesFuture = _loadSelectedDate();
    });
  }

  void _openMatch(FootballMatch match) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MatchDetailsScreen(fixtureId: match.id),
      ),
    );
  }

  bool _isSameDate(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  String get _selectedDateTitle {
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);

    final yesterday = normalizedToday.subtract(const Duration(days: 1));

    if (_isSameDate(_selectedDate, normalizedToday)) {
      return 'Важни мачове днес';
    }

    if (_isSameDate(_selectedDate, yesterday)) {
      return 'Мачове от вчера';
    }

    return 'Мачове от избраната дата';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);

    final availableDates = [
      today.subtract(const Duration(days: 2)),
      today.subtract(const Duration(days: 1)),
      today,
    ];

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
      body: Column(
        children: [
          _DateSelector(
            dates: availableDates,
            selectedDate: _selectedDate,
            onSelected: _selectDate,
            isSameDate: _isSameDate,
          ),
          Expanded(
            child: FutureBuilder<List<FootballMatch>>(
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
                    color: const Color(0xFF35D07F),
                    child: ListView(
                      children: const [
                        SizedBox(height: 150),
                        Icon(
                          Icons.sports_soccer,
                          size: 54,
                          color: Color(0xFF8492A6),
                        ),
                        SizedBox(height: 16),
                        Center(
                          child: Text(
                            'Няма мачове от избраните първенства.',
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
                          Expanded(
                            child: Text(
                              _selectedDateTitle,
                              style: const TextStyle(
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
          ),
        ],
      ),
    );
  }
}

class _DateSelector extends StatelessWidget {
  const _DateSelector({
    required this.dates,
    required this.selectedDate,
    required this.onSelected,
    required this.isSameDate,
  });

  final List<DateTime> dates;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelected;
  final bool Function(DateTime, DateTime) isSameDate;

  String _labelFor(DateTime date, int index) {
    if (index == 0) {
      return 'Преди 2 дни';
    }

    if (index == 1) {
      return 'Вчера';
    }

    return 'Днес';
  }

  String _formattedDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day.$month';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
      decoration: const BoxDecoration(
        color: Color(0xFF0B111B),
        border: Border(bottom: BorderSide(color: Color(0xFF202B3A))),
      ),
      child: Row(
        children: [
          for (var index = 0; index < dates.length; index++) ...[
            Expanded(
              child: _DateButton(
                label: _labelFor(dates[index], index),
                date: _formattedDate(dates[index]),
                selected: isSameDate(dates[index], selectedDate),
                onTap: () => onSelected(dates[index]),
              ),
            ),
            if (index < dates.length - 1) const SizedBox(width: 10),
          ],
        ],
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  const _DateButton({
    required this.label,
    required this.date,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String date;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFF244D3A) : const Color(0xFF182232),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 11),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  color: selected
                      ? const Color(0xFF5BE49B)
                      : const Color(0xFFAAB7C7),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                date,
                style: TextStyle(
                  color: selected ? Colors.white : const Color(0xFF8492A6),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
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
