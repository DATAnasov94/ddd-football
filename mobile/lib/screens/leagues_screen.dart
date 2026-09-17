import 'package:flutter/material.dart';

class LeaguesScreen extends StatelessWidget {
  const LeaguesScreen({super.key});

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
              'Първенства',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'Класиране и турнири',
              style: TextStyle(color: Color(0xFF8492A6), fontSize: 12),
            ),
          ],
        ),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.emoji_events_outlined,
                size: 58,
                color: Color(0xFF35D07F),
              ),
              SizedBox(height: 18),
              Text(
                'Първенства и класирания',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Тази секция ще бъде добавена в следващия етап.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF8492A6)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
