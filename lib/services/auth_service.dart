import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constant.dart';
import '../models/user_model.dart';
import 'storage_service.dart';

class AuthService {
  static Future<http.Response> _post(
    Uri uri, {
    required Map<String, String> headers,
    required String body,
    http.Client? client,
  }) {
    if (client != null) {
      return client.post(uri, headers: headers, body: body);
    }
    return http.post(uri, headers: headers, body: body);
  }

  static String? _fieldError(Map<String, dynamic> body, String field) {
    final errors = body['errors'];
    if (errors is! Map) return null;

    final value = errors[field];
    if (value is List && value.isNotEmpty) return value.first.toString();
    if (value is String) return value;
    return null;
  }

  static Future<void> login(
    String email,
    String password, {
    http.Client? client,
  }) async {
    final res = await _post(
      Uri.parse(ApiConstant.login),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'email': email, 'password': password}),
      client: client,
    );
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) {
      // Simpan token ke SharedPreferences
      await StorageService.saveToken(body['access_token']);
      return;
    }

    final message = body['message']?.toString().toLowerCase() ?? '';
    final emailError = _fieldError(body, 'email')?.toLowerCase() ?? '';
    final passwordError = _fieldError(body, 'password')?.toLowerCase() ?? '';
    final errorDetails = '$message $emailError $passwordError';
    if (res.statusCode == 401 ||
        errorDetails.contains('credential') ||
        errorDetails.contains('incorrect password')) {
      throw Exception('Email atau kata sandi salah. Periksa kembali datamu.');
    }
    if (emailError.isNotEmpty) {
      throw Exception(
        'Format email tidak valid. Periksa kembali alamat email.',
      );
    }
    if (passwordError.isNotEmpty) {
      throw Exception('Kata sandi tidak valid. Periksa kembali kata sandimu.');
    }
    throw Exception(body['message'] ?? 'Gagal masuk. Silakan coba lagi.');
  }

  static Future<void> register(
    String name,
    String email,
    String password, {
    http.Client? client,
  }) async {
    final res = await _post(
      Uri.parse(ApiConstant.register),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
      client: client,
    );
    if (res.statusCode != 201) {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final message = body['message']?.toString().toLowerCase() ?? '';
      final emailError = _fieldError(body, 'email')?.toLowerCase() ?? '';
      final passwordError = _fieldError(body, 'password')?.toLowerCase() ?? '';

      if (emailError.contains('taken') ||
          emailError.contains('already') ||
          message.contains('email has already')) {
        throw Exception('Email sudah terdaftar. Gunakan email lain.');
      }
      if (emailError.isNotEmpty) {
        throw Exception(
          'Format email tidak valid. Periksa kembali alamat email.',
        );
      }
      if (passwordError.isNotEmpty) {
        throw Exception(
          'Kata sandi tidak memenuhi persyaratan. Gunakan minimal 8 karakter.',
        );
      }
      if (res.statusCode == 422) {
        throw Exception(
          'Data pendaftaran tidak valid. Periksa kembali isianmu.',
        );
      }
      throw Exception(
        body['message'] ?? 'Pendaftaran gagal. Silakan coba lagi.',
      );
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
