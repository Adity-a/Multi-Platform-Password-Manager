import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../models/password_entry.dart';
import '../models/vault_header.dart';
import 'crypto_services.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';

class VaultService extends ChangeNotifier {
  VaultService();
  final CryptoService _crypto = CryptoService();

  List<PasswordEntry> _entries = [];
  String? _master;
  VaultHeader? _header;
  bool _dirty = false;

  List<PasswordEntry> get entries => List.unmodifiable(_entries);
  bool get isUnlocked => _master != null;
  bool get isDirty => _dirty;

  Future<File> _vaultFile() async {
    final dir = await getApplicationSupportDirectory();
    return File(p.join(dir.path, 'vault.v1.bin'));
  }

  Future<File> _headerFile() async {
    final dir = await getApplicationSupportDirectory();
    return File(p.join(dir.path, 'vault.v1.header.json'));
  }

  Future<bool> vaultExists() async {
    final f = await _vaultFile();
    final h = await _headerFile();
    return f.existsSync() && h.existsSync();
  }

  Future<void> createNewVault(String masterPin) async {
    _master = masterPin;
    _entries = [];
    await save();
  }

  Future<bool> unlock(String masterPin) async {
    final f = await _vaultFile();
    final h = await _headerFile();
    if (!f.existsSync() || !h.existsSync()) return false;
    try {
      final header = VaultHeader.fromJson(
          jsonDecode(await h.readAsString()) as Map<String, dynamic>);
      final data = await f.readAsBytes();
      final clear = await _crypto.decryptWithPassword(
          password: masterPin, header: header, ciphertextAndMac: data);
      _entries = PasswordEntry.decodeList(utf8.decode(clear));
      _master = masterPin;
      _header = header;
      _dirty = false;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> lock() async {
    _entries = [];
    _master = null;
    _header = null;
    _dirty = false;
    notifyListeners();
  }

  Future<void> save() async {
    if (_master == null) return;
    final (header, cipher) = await _crypto.encryptWithPassword(
      password: _master!,
      plaintext: utf8.encode(PasswordEntry.encodeList(_entries)),
    );
    _header = header;
    final f = await _vaultFile();
    final h = await _headerFile();
    await f.writeAsBytes(cipher, flush: true);
    await h.writeAsString(jsonEncode(header.toJson()), flush: true);
    _dirty = false;
  }

  void addOrUpdate(PasswordEntry e) {
    final idx = _entries.indexWhere((x) => x.id == e.id);
    if (idx >= 0) {
      e.updatedAt = DateTime.now();
      _entries[idx] = e;
    } else {
      _entries.add(e);
    }
    _dirty = true;
    notifyListeners();
  }

  void remove(String id) {
    _entries.removeWhere((e) => e.id == id);
    _dirty = true;
    notifyListeners();
  }

  Future<void> exportEncryptedBackup() async {
    final vaultBytes = await (await _vaultFile()).readAsBytes();
    final headerJson = jsonDecode(await (await _headerFile()).readAsString());

    final payload = {
      'format': 'flutter_password_manager_v1',
      'header': headerJson,
      'ciphertextAndMac': vaultBytes,
    };

    final ts = DateTime.now().toIso8601String().replaceAll(':', '-');
    final fileName = 'vault-backup-$ts.json';
    final bytes = utf8.encode(jsonEncode(payload));

    // Save to user-selected location
    await FileSaver.instance.saveFile(
      name: fileName,
      bytes: bytes,
      ext: 'json',
      mimeType: MimeType.json,
    );
  }

  /// Import vault from a user-picked encrypted backup file
  Future<bool> importEncryptedBackup(String masterPin) async {
    // Pick the file
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result == null || result.files.isEmpty) return false;

    final file = File(result.files.single.path!);

    try {
      final payload = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      if (payload['format'] != 'flutter_password_manager_v1') return false;

      final header = VaultHeader.fromJson(Map<String, dynamic>.from(payload['header']));
      final bytes = List<int>.from(payload['ciphertextAndMac']);

      // Attempt decryption with user PIN
      final clear = await _crypto.decryptWithPassword(
        password: masterPin,
        header: header,
        ciphertextAndMac: bytes,
      );

      _entries = PasswordEntry.decodeList(utf8.decode(clear));
      _master = masterPin;
      _header = header;
      await save();
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}