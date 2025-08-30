/// Constants for Hive box names used throughout the app
class HiveBoxes {
  // Private constructor to prevent instantiation
  HiveBoxes._();

  /// Main storage box for domain models stored as JSON strings
  static const String main = 'main_storage';

  /// Settings and configuration storage
  static const String settings = 'app_settings';

  /// User profile and authentication data
  static const String profile = 'user_profile';

  /// Progress events and journaling data
  static const String progress = 'progress_journal';

  /// Training programs and sessions
  static const String training = 'training_data';

  /// Migration metadata and schema versioning
  static const String migrations = 'migration_metadata';

  /// All box names for bulk operations
  static const List<String> allBoxes = [
    main,
    settings,
    profile,
    progress,
    training,
    migrations,
  ];
}
