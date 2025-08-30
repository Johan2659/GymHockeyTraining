/// Base model classes for the Hockey Gym app
library;

/// Base model interface
abstract class Model {
  Map<String, dynamic> toJson();
}

/// User model
class User implements Model {
  const User({
    required this.id,
    required this.name,
    required this.email,
  });
  
  final String id;
  final String name;
  final String email;
  
  // TODO: Add more user fields as needed
  
  @override
  Map<String, dynamic> toJson() {
    // TODO: Implement JSON serialization
    throw UnimplementedError();
  }
  
  factory User.fromJson(Map<String, dynamic> json) {
    // TODO: Implement JSON deserialization
    throw UnimplementedError();
  }
}

/// Program model
class Program implements Model {
  const Program({
    required this.id,
    required this.name,
    required this.description,
  });
  
  final String id;
  final String name;
  final String description;
  
  // TODO: Add more program fields as needed
  
  @override
  Map<String, dynamic> toJson() {
    // TODO: Implement JSON serialization
    throw UnimplementedError();
  }
  
  factory Program.fromJson(Map<String, dynamic> json) {
    // TODO: Implement JSON deserialization
    throw UnimplementedError();
  }
}

/// Progress event model
class ProgressEvent implements Model {
  const ProgressEvent({
    required this.id,
    required this.timestamp,
    required this.type,
    required this.data,
  });
  
  final String id;
  final DateTime timestamp;
  final String type;
  final Map<String, dynamic> data;
  
  // TODO: Add more progress event fields as needed
  
  @override
  Map<String, dynamic> toJson() {
    // TODO: Implement JSON serialization
    throw UnimplementedError();
  }
  
  factory ProgressEvent.fromJson(Map<String, dynamic> json) {
    // TODO: Implement JSON deserialization
    throw UnimplementedError();
  }
}

// TODO: Add more model classes as needed
