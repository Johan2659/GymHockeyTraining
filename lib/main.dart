import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await _initializeHive();
  
  runApp(
    const ProviderScope(
      child: HockeyGymApp(),
    ),
  );
}

Future<void> _initializeHive() async {
  // Initialize Hive
  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);
  
  // Get or create encryption key
  const secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );
  
  // Try to get existing encryption key
  String? keyString = await secureStorage.read(key: 'hive_encryption_key');
  
  Uint8List encryptionKey;
  if (keyString == null) {
    // Generate new encryption key
    encryptionKey = Uint8List.fromList(Hive.generateSecureKey());
    // Store the key securely
    await secureStorage.write(
      key: 'hive_encryption_key',
      value: base64Encode(encryptionKey),
    );
  } else {
    // Use existing key
    encryptionKey = Uint8List.fromList(base64Decode(keyString));
  }
  
  // Open encrypted boxes
  await Hive.openBox<Map<dynamic, dynamic>>(
    'profile',
    encryptionCipher: HiveAesCipher(encryptionKey),
  );
  
  await Hive.openBox<Map<dynamic, dynamic>>(
    'program_state',
    encryptionCipher: HiveAesCipher(encryptionKey),
  );
  
  await Hive.openBox<Map<dynamic, dynamic>>(
    'progress_events',
    encryptionCipher: HiveAesCipher(encryptionKey),
  );
}
