import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gymhockeytraining/app/di.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('Quick Diagnostic Tests', () {
    late ProviderContainer container;

    setUp(() async {
      await TestHelpers.initializeTestEnvironment();
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('Basic DI providers work', () async {
      try {
        final programRepo = container.read(programRepositoryProvider);
        expect(programRepo, isNotNull);
        print('✅ ProgramRepository created successfully');

        final progressRepo = container.read(progressRepositoryProvider);
        expect(progressRepo, isNotNull);
        print('✅ ProgressRepository created successfully');

        final stateRepo = container.read(programStateRepositoryProvider);
        expect(stateRepo, isNotNull);
        print('✅ ProgramStateRepository created successfully');

        final profileRepo = container.read(profileRepositoryProvider);
        expect(profileRepo, isNotNull);
        print('✅ ProfileRepository created successfully');
      } catch (e, stack) {
        print('❌ DI provider error: $e');
        print('Stack: $stack');
        rethrow;
      }
    });

    test('Basic repository operations work', () async {
      try {
        final programRepo = container.read(programRepositoryProvider);
        final programs = await programRepo.getAll();
        expect(programs, isNotNull);
        print(
            '✅ ProgramRepository.getAll() works: ${programs.length} programs');

        final progressRepo = container.read(progressRepositoryProvider);
        final events = await progressRepo.getRecent();
        expect(events, isNotNull);
        print(
            '✅ ProgressRepository.getRecent() works: ${events.length} events');
      } catch (e, stack) {
        print('❌ Repository operation error: $e');
        print('Stack: $stack');
        rethrow;
      }
    });
  });
}
