import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/constants.dart';
import '../models/db_credentials.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService()
      : _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
          iOptions: IOSOptions(
            accessibility: KeychainAccessibility.first_unlock_this_device,
          ),
        );

  // --- Credential Management ---

  Future<void> saveCredentials(DbCredentials credentials) async {
    await _storage.write(
      key: AppConstants.keyDbAdvancedMode,
      value: credentials.isAdvancedMode.toString(),
    );

    if (credentials.isAdvancedMode) {
      await _storage.write(
        key: AppConstants.keyDbRawUri,
        value: credentials.rawUri,
      );
    } else {
      await Future.wait([
        _storage.write(key: AppConstants.keyDbHost, value: credentials.host),
        _storage.write(key: AppConstants.keyDbPort, value: credentials.port),
        _storage.write(
            key: AppConstants.keyDbName, value: credentials.databaseName),
        _storage.write(
            key: AppConstants.keyDbUsername, value: credentials.username),
        _storage.write(
            key: AppConstants.keyDbPassword, value: credentials.password),
      ]);
    }
  }

  Future<DbCredentials?> getCredentials() async {
    final modeStr =
        await _storage.read(key: AppConstants.keyDbAdvancedMode);
    if (modeStr == null) return null;

    final isAdvanced = modeStr == 'true';

    if (isAdvanced) {
      final uri = await _storage.read(key: AppConstants.keyDbRawUri);
      if (uri == null || uri.isEmpty) return null;
      return DbCredentials(isAdvancedMode: true, rawUri: uri);
    }

    final results = await Future.wait([
      _storage.read(key: AppConstants.keyDbHost),
      _storage.read(key: AppConstants.keyDbPort),
      _storage.read(key: AppConstants.keyDbName),
      _storage.read(key: AppConstants.keyDbUsername),
      _storage.read(key: AppConstants.keyDbPassword),
    ]);

    final host = results[0];
    if (host == null || host.isEmpty) return null;

    return DbCredentials(
      host: host,
      port: results[1] ?? AppConstants.defaultPort,
      databaseName: results[2] ?? AppConstants.defaultDatabase,
      username: results[3] ?? '',
      password: results[4] ?? '',
    );
  }

  Future<void> clearCredentials() async {
    await Future.wait([
      _storage.delete(key: AppConstants.keyDbHost),
      _storage.delete(key: AppConstants.keyDbPort),
      _storage.delete(key: AppConstants.keyDbName),
      _storage.delete(key: AppConstants.keyDbUsername),
      _storage.delete(key: AppConstants.keyDbPassword),
      _storage.delete(key: AppConstants.keyDbAdvancedMode),
      _storage.delete(key: AppConstants.keyDbRawUri),
    ]);
  }

  // --- Custom Categories ---

  Future<void> saveCustomCategories(List<String> categories) async {
    await _storage.write(
      key: AppConstants.keyCustomCategories,
      value: categories.join('|'),
    );
  }

  Future<List<String>> getCustomCategories() async {
    final raw = await _storage.read(key: AppConstants.keyCustomCategories);
    if (raw == null || raw.isEmpty) return [];
    return raw.split('|');
  }
}
