import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'di.g.dart';

// Logger provider
@riverpod
Logger logger(Ref ref) {
  return Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.none,
    ),
  );
}

// Secure storage provider
@riverpod
FlutterSecureStorage secureStorage(Ref ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );
}

// Hive boxes providers
@riverpod
Box<Map<dynamic, dynamic>> profileBox(Ref ref) {
  return Hive.box<Map<dynamic, dynamic>>('profile');
}

@riverpod
Box<Map<dynamic, dynamic>> programStateBox(Ref ref) {
  return Hive.box<Map<dynamic, dynamic>>('program_state');
}

@riverpod
Box<Map<dynamic, dynamic>> progressEventsBox(Ref ref) {
  return Hive.box<Map<dynamic, dynamic>>('progress_events');
}
