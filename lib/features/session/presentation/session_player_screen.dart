import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SessionPlayerScreen extends ConsumerWidget {
  final String programId;
  final String week;
  final String session;

  const SessionPlayerScreen({
    super.key,
    required this.programId,
    required this.week,
    required this.session,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Session Player'),
            Text(
              'Program $programId - Week $week - Session $session',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.play_circle_outline,
              size: 64,
              color: Colors.blue,
            ),
            SizedBox(height: 16),
            Text(
              'Session Player',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'This screen will contain the session player interface',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
