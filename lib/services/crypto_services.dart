import 'dart:convert';
import 'dart:math';
import 'package:cryptography/cryptography.dart';
import '../models/vault_header.dart';

class CryptoService {
  static const int saltLen = 16;
  static const int nonceLen = 12; // GCM
  static const int defaultIterations = 310-000; // strong, but tune for desktop/mobile

  final AesGcm _aes = AesGcm.with256bits();

  Future<(VaultHeader, List<int>)> encryptWithPassword({
    required String password,
    required List<int> plaintext,
  }) async {
    final rand = Random.secure();
    final salt = List<int>.generate(saltLen, (_) => rand.nextInt(256));
    final nonce = List<int>.generate(nonceLen, (_) => rand.nextInt(256));

    final secretKey = await _deriveKey(password, salt, defaultIterations);
    final secretBox = await _aes.encrypt(plaintext,
        secretKey: secretKey, nonce: nonce, aad: _aad());

    final header = VaultHeader(
      salt: salt,
      iterations: defaultIterations,
      kdf: 'pbkdf2-hmac-sha256',
      nonce: nonce,
    );
    return (header, secretBox.cipherText + secretBox.mac.bytes);
  }

  Future<List<int>> decryptWithPassword({
    required String password,
    required VaultHeader header,
    required List<int> ciphertextAndMac,
  }) async {
    final secretKey =
    await _deriveKey(password, header.salt, header.iterations);
    final macBytes = ciphertextAndMac.sublist(ciphertextAndMac.length - 16);
    final cipher = ciphertextAndMac.sublist(0, ciphertextAndMac.length - 16);
    final box = SecretBox(cipher, nonce: header.nonce, mac: Mac(macBytes));
    final clear = await _aes.decrypt(box, secretKey: secretKey, aad: _aad());
    return clear;
  }

  Future<SecretKey> _deriveKey(String password, List<int> salt, int iters) async {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: iters,
      bits: 256,
    );
    return pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: salt,
    );
  }

  List<int> _aad() => utf8.encode('flutter_password_manager_v1');
}