import 'package:flutter/material.dart';

import '../models/football_match.dart';

class MatchCard extends StatelessWidget {
  const MatchCard({required this.match, required this.onTap, super.key});

  final FootballMatch match;
  final VoidCallback onTap;

  String get formattedTime {
    final hour = match.date.hour.toString().padLeft(2, '0');
    final minute = match.date.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  String get scoreText {
    if (match.homeGoals == null || match.awayGoals == null) {
      return formattedTime;
    }

    return '${match.homeGoals}  –  ${match.awayGoals}';
  }

  Widget _buildTeamLogo(String? logoUrl) {
    if (logoUrl == null || logoUrl.isEmpty) {
      return const CircleAvatar(radius: 20, child: Icon(Icons.sports_soccer));
    }

    return SizedBox(
      width: 42,
      height: 42,
      child: Image.network(
        logoUrl,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) {
          return const CircleAvatar(
            radius: 20,
            child: Icon(Icons.sports_soccer),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      color: const Color(0xFF182232),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: match.isLive
              ? const Color(0xFF35D07F)
              : const Color(0xFF293548),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Row(
                children: [
                  if (match.leagueLogo != null)
                    Image.network(
                      match.leagueLogo!,
                      width: 22,
                      height: 22,
                      errorBuilder: (_, __, ___) {
                        return const SizedBox.shrink();
                      },
                    ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      match.leagueName,
                      style: const TextStyle(
                        color: Color(0xFFAAB7C7),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (match.isLive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF35D07F),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        match.elapsed == null ? 'LIVE' : "${match.elapsed}'",
                        style: const TextStyle(
                          color: Color(0xFF07140D),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    )
                  else
                    Text(
                      match.statusShort == 'NS'
                          ? formattedTime
                          : match.statusShort,
                      style: const TextStyle(
                        color: Color(0xFFAAB7C7),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        _buildTeamLogo(match.homeTeamLogo),
                        const SizedBox(height: 10),
                        Text(
                          match.homeTeamName,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 90,
                    child: Column(
                      children: [
                        Text(
                          scoreText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          match.statusLong,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF8492A6),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        _buildTeamLogo(match.awayTeamLogo),
                        const SizedBox(height: 10),
                        Text(
                          match.awayTeamName,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
