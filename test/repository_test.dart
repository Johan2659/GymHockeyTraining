import 'package:flutter_test/flutter_test.dart';
import 'package:gymhockeytraining/core/models/models.dart';
import 'package:gymhockeytraining/core/repositories/repositories.dart';
import 'package:gymhockeytraining/data/repositories_impl/repositories_impl.dart';

void main() {
  group('Repository Layer Tests', () {
    group('ProgramRepository', () {
      late ProgramRepository repository;

      setUp(() {
        repository = ProgramRepositoryImpl();
      });

      test('should implement repository interface', () {
        expect(repository, isA<ProgramRepository>());
      });

      test('should handle getById for non-existent program', () async {
        final program = await repository.getById('non_existent');
        expect(program, isNull);
      });

      test('should handle getAll without errors', () async {
        final programs = await repository.getAll();
        expect(programs, isA<List<Program>>());
      });

      test('should handle listByRole without errors', () async {
        final programs = await repository.listByRole(UserRole.attacker);
        expect(programs, isA<List<Program>>());
      });
    });

    group('ProgressRepository', () {
      late ProgressRepository repository;

      setUp(() {
        repository = ProgressRepositoryImpl();
      });

      test('should implement repository interface', () {
        expect(repository, isA<ProgressRepository>());
      });

      test('should provide watchAll stream', () {
        final stream = repository.watchAll();
        expect(stream, isA<Stream<List<ProgressEvent>>>());
      });

      test('should handle getRecent without errors', () async {
        final events = await repository.getRecent();
        expect(events, isA<List<ProgressEvent>>());
      });
    });

    group('ProgramStateRepository', () {
      late ProgramStateRepository repository;

      setUp(() {
        repository = ProgramStateRepositoryImpl();
      });

      test('should implement repository interface', () {
        expect(repository, isA<ProgramStateRepository>());
      });

      test('should handle get for no state', () async {
        final state = await repository.get();
        expect(state, isNull);
      });

      test('should provide watch stream', () {
        final stream = repository.watch();
        expect(stream, isA<Stream<ProgramState?>>());
      });
    });

    group('ProfileRepository', () {
      late ProfileRepository repository;

      setUp(() {
        repository = ProfileRepositoryImpl();
      });

      test('should implement repository interface', () {
        expect(repository, isA<ProfileRepository>());
      });

      test('should handle get for no profile', () async {
        final profile = await repository.get();
        expect(profile, isNull);
      });

      test('should provide watch stream', () {
        final stream = repository.watch();
        expect(stream, isA<Stream<Profile?>>());
      });

      test('should handle exists check', () async {
        final exists = await repository.exists();
        expect(exists, isA<bool>());
      });
    });
  });
}
