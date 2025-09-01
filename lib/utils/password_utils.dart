import 'dart:math';

class PasswordUtils {
  static const _lowercase = "abcdefghijklmnopqrstuvwxyz";
  static const _uppercase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  static const _numbers = "0123456789";
  static const _special = "!@#\$%^&*()-_=+[]{}|<>?";

  static String generate({
    int length = 16,
    bool hasLower = true,
    bool hasUpper = true,
    bool hasNumbers = true,
    bool hasSpecial = true,
  }) {
    String chars = "";
    if (hasLower) chars += _lowercase;
    if (hasUpper) chars += _uppercase;
    if (hasNumbers) chars += _numbers;
    if (hasSpecial) chars += _special;

    if (chars.isEmpty) {
      throw ArgumentError("At least one character set must be selected.");
    }

    final rand = Random.secure();
    return List.generate(length, (i) => chars[rand.nextInt(chars.length)]).join();
  }
}