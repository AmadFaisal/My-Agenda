import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constant.dart';
import '../models/user_model.dart';
import 'storage_service.dart';

class AuthService {
  static Future<void> login(String email, String password) async {
    final res = await http.post(
      Uri.parse(ApiConstant.login),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'email': email, 'password': password}),
    );
    final body = jsonDecode(res.body);
    if (res.statusCode == 200) {
      // Simpan token ke SharedPreferences
      await StorageService.saveToken(body['access_token']);
    } else {
      throw Exception(body['message'] ?? 'Login gagal');
    }
  }

  static Future<void> register(
    String name,
    String email,
    String password,
  ) async {
    final res = await http.post(
      Uri.parse(ApiConstant.register),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    if (res.statusCode != 201) {
      final body = jsonDecode(res.body);
      throw Exception(body['message'] ?? 'Register gagal');
    }
  }

  static Future<UserModel> fetchUser() async {
    final token = await StorageService.getToken();
    final res = await http.get(
      Uri.parse(ApiConstant.user),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(res.body));
    }
    throw Exception('Gagal mengambil data user');
  }

  static Future<void> logout() async {
    final token = await StorageService.getToken();
    await http.post(
      Uri.parse(ApiConstant.logout),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );
    await StorageService.clear();
  }
}
