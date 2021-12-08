import 'dart:core';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionService {
  static final storage = new FlutterSecureStorage();

  static Future<void> setToken(String token) async {
    return storage.write(key: 'token', value: token);
  }

  static Future<void> deleteToken() async {
    return storage.delete(key: 'token');
  }

  static Future<String> getToken() async {
    var token = await storage.read(key: 'token');
    return token;
  }
}
