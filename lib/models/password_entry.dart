import 'dart:convert';

class PasswordEntry {
  final String id; // uuid
  String title; // site/app
  String username;
  String password; // kept in memory only after decrypt
  //String? url;
  //String? note;
  DateTime createdAt;
  DateTime updatedAt;

  PasswordEntry({
    required this.id,
    required this.title,
    required this.username,
    required this.password,
    //this.url,
    //this.note,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'username': username,
    'password': password,
    //'url': url,
    //'note': note,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  static PasswordEntry fromJson(Map<String, dynamic> j) => PasswordEntry(
    id: j['id'] as String,
    title: j['title'] as String,
    username: j['username'] as String,
    password: j['password'] as String,
    //url: j['url'] as String?,
    //note: j['note'] as String?,
    createdAt: DateTime.parse(j['createdAt'] as String),
    updatedAt: DateTime.parse(j['updatedAt'] as String),
  );

  static String encodeList(List<PasswordEntry> list) =>
      jsonEncode(list.map((e) => e.toJson()).toList());
  static List<PasswordEntry> decodeList(String s) =>
      (jsonDecode(s) as List).map((e) => PasswordEntry.fromJson(e)).toList();
}