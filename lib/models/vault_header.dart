class VaultHeader {
  final List<int> salt; // 16 bytes
  final int iterations; // PBKDF2 iterations
  final String kdf; // 'pbkdf2-hmac-sha256'
  final List<int> nonce; // 12 bytes for AES-GCM

  VaultHeader({
    required this.salt,
    required this.iterations,
    required this.kdf,
    required this.nonce,
  });

  Map<String, dynamic> toJson() => {
    'salt': salt,
    'iterations': iterations,
    'kdf': kdf,
    'nonce': nonce,
  };

  static VaultHeader fromJson(Map<String, dynamic> j) => VaultHeader(
    salt: List<int>.from(j['salt'] as List),
    iterations: j['iterations'] as int,
    kdf: j['kdf'] as String,
    nonce: List<int>.from(j['nonce'] as List),
  );
}