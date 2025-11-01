import 'package:flutter_test/flutter_test.dart';
import 'package:gymhockeytraining/data/datasources/local_session_source.dart';

void main() {
  group('LocalSessionSource Tests', () {
    late LocalSessionSource source;

    setUp(() {
      source = LocalSessionSource();
    });

    group('getSessionById', () {
      test('should load attacker sessions', () async {
        final session = await source.getSessionById('attacker_w1_s1');
        expect(session, isNotNull);
        expect(session!.id, equals('attacker_w1_s1'));
      });

      test('should load defender sessions', () async {
        final session = await source.getSessionById('defender_w1_s1');
        expect(session, isNotNull);
        expect(session!.id, equals('defender_w1_s1'));
      });

      test('should load goalie sessions', () async {
        final session = await source.getSessionById('goalie_w1_s1');
        expect(session, isNotNull);
        expect(session!.id, equals('goalie_w1_s1'));
      });

      test('should load referee sessions', () async {
        final session = await source.getSessionById('referee_w1_s1');
        expect(session, isNotNull);
        expect(session!.id, equals('referee_w1_s1'));
      });

      test('should return null for non-existent session', () async {
        final session = await source.getSessionById('invalid_session_id');
        expect(session, isNull);
      });
    });

    group('getSessionsByProgramId', () {
      test('should load all attacker sessions', () async {
        final sessions = await source.getSessionsByProgramId('hockey_attacker_2025');
        expect(sessions, isNotEmpty);
        expect(sessions.first.id, startsWith('attacker_w'));
      });

      test('should load all defender sessions', () async {
        final sessions = await source.getSessionsByProgramId('hockey_defender_2025');
        expect(sessions, isNotEmpty);
        expect(sessions.first.id, startsWith('defender_w'));
      });

      test('should load all goalie sessions', () async {
        final sessions = await source.getSessionsByProgramId('hockey_goalie_2025');
        expect(sessions, isNotEmpty);
        expect(sessions.first.id, startsWith('goalie_w'));
      });

      test('should load all referee sessions', () async {
        final sessions = await source.getSessionsByProgramId('hockey_referee_2025');
        expect(sessions, isNotEmpty);
        expect(sessions.first.id, startsWith('referee_w'));
      });

      test('should return empty list for invalid program', () async {
        final sessions = await source.getSessionsByProgramId('invalid_program_id');
        expect(sessions, isEmpty);
      });
    });

    group('getSessionsByWeek', () {
      test('should load attacker sessions by week', () async {
        final sessions = await source.getSessionsByWeek('hockey_attacker_2025', 0); // Week 1
        expect(sessions, isNotEmpty);
        expect(sessions.every((s) => s.id.startsWith('attacker_w1_')), isTrue);
      });

      test('should load defender sessions by week', () async {
        final sessions = await source.getSessionsByWeek('hockey_defender_2025', 0); // Week 1
        expect(sessions, isNotEmpty);
        expect(sessions.every((s) => s.id.startsWith('defender_w1_')), isTrue);
      });

      test('should load goalie sessions by week', () async {
        final sessions = await source.getSessionsByWeek('hockey_goalie_2025', 0); // Week 1
        expect(sessions, isNotEmpty);
        expect(sessions.every((s) => s.id.startsWith('goalie_w1_')), isTrue);
      });

      test('should load referee sessions by week', () async {
        final sessions = await source.getSessionsByWeek('hockey_referee_2025', 0); // Week 1
        expect(sessions, isNotEmpty);
        expect(sessions.every((s) => s.id.startsWith('referee_w1_')), isTrue);
      });

      test('should return empty list for invalid week', () async {
        final sessions = await source.getSessionsByWeek('hockey_attacker_2025', 99);
        expect(sessions, isEmpty);
      });

      test('should return empty list for invalid program', () async {
        final sessions = await source.getSessionsByWeek('invalid_program_id', 0);
        expect(sessions, isEmpty);
      });
    });
  });
}