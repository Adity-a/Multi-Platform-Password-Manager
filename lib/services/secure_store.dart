import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Thin wrapper around platform secure storage (Keystore/Keychain).
/// On desktop, flutter_secure_storage uses best‑effort file‑based storage.
class SecureStore {
  static const _storage = FlutterSecureStorage();

  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> read(String key) async {
    return _storage.read(key: key);
  }

  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  bool get isDesktop => Platform.isWindows || Platform.isLinux || Platform.isMacOS;
}