import 'package:logger/logger.dart';
import '../../core/models/models.dart';
import '../../core/repositories/profile_repository.dart';
import '../datasources/local_prefs_source.dart';

/// Implementation of ProfileRepository using local data source
class ProfileRepositoryImpl implements ProfileRepository {
  final LocalPrefsSource _localSource;
  static final _logger = Logger();

  ProfileRepositoryImpl({
    LocalPrefsSource? localSource,
  }) : _localSource = localSource ?? LocalPrefsSource();

  @override
  Future<Profile?> get() async {
    try {
      _logger.d('ProfileRepositoryImpl: Getting user profile');
      
      final profile = await _localSource.getProfile();
      
      if (profile != null) {
        _logger.i('ProfileRepositoryImpl: Found user profile');
      } else {
        _logger.d('ProfileRepositoryImpl: No profile found');
      }
      
      return profile;
      
    } catch (e, stackTrace) {
      _logger.e('ProfileRepositoryImpl: Failed to get profile', 
                error: e, stackTrace: stackTrace);
      return null;
    }
  }

  @override
  Future<bool> save(Profile profile) async {
    try {
      _logger.d('ProfileRepositoryImpl: Saving user profile');
      
      final success = await _localSource.saveProfile(profile);
      
      if (success) {
        _logger.i('ProfileRepositoryImpl: Successfully saved profile');
      } else {
        _logger.e('ProfileRepositoryImpl: Failed to save profile');
      }
      
      return success;
      
    } catch (e, stackTrace) {
      _logger.e('ProfileRepositoryImpl: Error saving profile', 
                error: e, stackTrace: stackTrace);
      return false;
    }
  }

  @override
  Stream<Profile?> watch() {
    try {
      _logger.d('ProfileRepositoryImpl: Creating watch stream for profile');
      return _localSource.watchProfile();
    } catch (e, stackTrace) {
      _logger.e('ProfileRepositoryImpl: Error creating watch stream', 
                error: e, stackTrace: stackTrace);
      return Stream.value(null);
    }
  }

  @override
  Future<bool> updateRole(UserRole role) async {
    try {
      _logger.d('ProfileRepositoryImpl: Updating role to $role');
      
      final currentProfile = await get();
      final baseProfile = currentProfile ?? const Profile(
        role: UserRole.attacker,
        language: 'English',
        units: 'kg',
        theme: 'dark',
      );
      
      final updatedProfile = baseProfile.copyWith(role: role);
      return await save(updatedProfile);
      
    } catch (e, stackTrace) {
      _logger.e('ProfileRepositoryImpl: Error updating role', 
                error: e, stackTrace: stackTrace);
      return false;
    }
  }

  @override
  Future<bool> updateLanguage(String language) async {
    try {
      _logger.d('ProfileRepositoryImpl: Updating language to $language');
      
      final currentProfile = await get();
      final baseProfile = currentProfile ?? const Profile(
        role: UserRole.attacker,
        language: 'English',
        units: 'kg',
        theme: 'dark',
      );
      
      final updatedProfile = baseProfile.copyWith(language: language);
      return await save(updatedProfile);
      
    } catch (e, stackTrace) {
      _logger.e('ProfileRepositoryImpl: Error updating language', 
                error: e, stackTrace: stackTrace);
      return false;
    }
  }

  @override
  Future<bool> updateUnits(String units) async {
    try {
      _logger.d('ProfileRepositoryImpl: Updating units to $units');
      
      final currentProfile = await get();
      final baseProfile = currentProfile ?? const Profile(
        role: UserRole.attacker,
        language: 'English',
        units: 'kg',
        theme: 'dark',
      );
      
      final updatedProfile = baseProfile.copyWith(units: units);
      return await save(updatedProfile);
      
    } catch (e, stackTrace) {
      _logger.e('ProfileRepositoryImpl: Error updating units', 
                error: e, stackTrace: stackTrace);
      return false;
    }
  }

  @override
  Future<bool> updateTheme(String theme) async {
    try {
      _logger.d('ProfileRepositoryImpl: Updating theme to $theme');
      
      final currentProfile = await get();
      final baseProfile = currentProfile ?? const Profile(
        role: UserRole.attacker,
        language: 'English',
        units: 'kg',
        theme: 'dark',
      );
      
      final updatedProfile = baseProfile.copyWith(theme: theme);
      return await save(updatedProfile);
      
    } catch (e, stackTrace) {
      _logger.e('ProfileRepositoryImpl: Error updating theme', 
                error: e, stackTrace: stackTrace);
      return false;
    }
  }

  @override
  Future<bool> clear() async {
    try {
      _logger.w('ProfileRepositoryImpl: Clearing user profile');
      
      final success = await _localSource.clearProfile();
      
      if (success) {
        _logger.w('ProfileRepositoryImpl: Successfully cleared profile');
      } else {
        _logger.e('ProfileRepositoryImpl: Failed to clear profile');
      }
      
      return success;
      
    } catch (e, stackTrace) {
      _logger.e('ProfileRepositoryImpl: Error clearing profile', 
                error: e, stackTrace: stackTrace);
      return false;
    }
  }

  @override
  Future<bool> exists() async {
    try {
      return await _localSource.profileExists();
    } catch (e, stackTrace) {
      _logger.e('ProfileRepositoryImpl: Error checking profile existence', 
                error: e, stackTrace: stackTrace);
      return false;
    }
  }
}
