import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Salted, iterated SHA-256 hashing for the 6-digit app-lock PIN.
///
/// The PIN itself is never persisted — only [PinHash.salt] and
/// [PinHash.hash] are written to secure storage, so a stolen backup of the
/// storage values can't be reversed back into the PIN without brute-forcing
/// [_iterations] rounds per guess.
class PinHash {
  const PinHash({required this.salt, required this.hash});

  final String salt;
  final String hash;
}

class PinHasher {
  const PinHasher._();

  static const _iterations = 20000;
  static const _saltBytes = 16;

  static PinHash create(String pin) {
    final salt = _randomSalt();
    return PinHash(salt: salt, hash: _derive(pin, salt));
  }

  static bool verify(String pin, PinHash stored) {
    return _derive(pin, stored.salt) == stored.hash;
  }

  static String _derive(String pin, String salt) {
    List<int> digest = utf8.encode('$salt:$pin');
    for (var i = 0; i < _iterations; i++) {
      digest = sha256.convert(digest).bytes;
    }
    return base64Encode(digest);
  }

  static String _randomSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(_saltBytes, (_) => random.nextInt(256));
    return base64Encode(bytes);
  }
}
