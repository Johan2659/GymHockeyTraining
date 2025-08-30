/// Storage interfaces and implementations for the Hockey Gym app
library;

/// Base storage interface
abstract class Storage<T> {
  Future<void> save(String key, T data);
  Future<T?> load(String key);
  Future<void> delete(String key);
  Future<void> clear();
}

/// Hive storage implementation
class HiveStorage<T> implements Storage<T> {
  // TODO: Implement Hive storage methods
  
  @override
  Future<void> save(String key, T data) async {
    // TODO: Save data to Hive box
    throw UnimplementedError();
  }
  
  @override
  Future<T?> load(String key) async {
    // TODO: Load data from Hive box
    throw UnimplementedError();
  }
  
  @override
  Future<void> delete(String key) async {
    // TODO: Delete data from Hive box
    throw UnimplementedError();
  }
  
  @override
  Future<void> clear() async {
    // TODO: Clear all data from Hive box
    throw UnimplementedError();
  }
}

// TODO: Add more storage implementations as needed
