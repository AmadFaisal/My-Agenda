import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constant.dart';
import '../models/trip_type_model.dart';
import 'storage_service.dart';

class TripTypeService {
  static Future<Map<String, String>> _headers() async {
    final token = await StorageService.getToken();
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<List<TripTypeModel>> getAll() async {
    final res = await http.get(
      Uri.parse(ApiConstant.tripTypes),
      headers: await _headers(),
    );
    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as List)
          .map((e) => TripTypeModel.fromJson(e))
          .toList();
    }
    throw Exception('Gagal load kategori');
  }

  static Future<void> create(String name) async {
    final res = await http.post(
      Uri.parse(ApiConstant.tripTypes),
      headers: await _headers(),
      body: jsonEncode({'name': name}),
    );
    if (res.statusCode != 201) throw Exception('Gagal tambah kategori');
  }

  static Future<void> update(int id, String name) async {
    final res = await http.put(
      Uri.parse(ApiConstant.tripTypeById(id)),
      headers: await _headers(),
      body: jsonEncode({'name': name}),
    );
    if (res.statusCode != 200) throw Exception('Gagal update kategori');
  }

  static Future<void> delete(int id) async {
    final res = await http.delete(
      Uri.parse(ApiConstant.tripTypeById(id)),
      headers: await _headers(),
    );
    if (res.statusCode != 200) throw Exception('Gagal hapus kategori');
  }
}
