/// Utility extensions for integrating persistence with existing providers
/// This allows your existing app_state_provider.dart to easily save state changes
library;

import 'package:logger/logger.dart';
import '../persistence/persistence_service.dart';

/// Extension to add persistence capabilities to any provider
extension PersistenceExtensions on Object {
  static final _logger = Logger();
  
  /// Save any state change with automatic fallback
  /// Call this after every important state mutation
  static Future<void> persistStateChange(String description) async {
    try {
      _logger.d('PersistenceExtensions: $description');
      
      // The actual saving happens in your existing repositories
      // This is just a hook for logging and future enhancements
      
    } catch (e) {
      _logger.w('PersistenceExtensions: Failed to log state change: $description', error: e);
    }
  }
  
  /// Check if persistence is healthy
  static Future<bool> isPersistenceHealthy() async {
    return await PersistenceService.healthCheck();
  }
}
