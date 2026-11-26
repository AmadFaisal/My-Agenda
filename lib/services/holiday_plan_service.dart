import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constant.dart';
import '../models/holiday_plan_model.dart';
import 'storage_service.dart';

class HolidayPlanService {
  static Future<Map<String, String>> _headers() async {
    final token = await StorageService.getToken();
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<List<HolidayPlanModel>> getAll({int? tripTypeId}) async {
    final url = tripTypeId != null
        ? '${ApiConstant.holidayPlans}?trip_type_id=$tripTypeId'
        : ApiConstant.holidayPlans;
    final res = await http.get(Uri.parse(url), headers: await _headers());
    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as List)
          .map((e) => HolidayPlanModel.fromJson(e))
          .toList();
    }
    throw Exception('Gagal load rencana libur');
  }

  static Future<void> create({
    required int tripTypeId,
    required String title,
    String? notes,
    String? holidayDate,
  }) async {
    final res = await http.post(
      Uri.parse(ApiConstant.holidayPlans),
      headers: await _headers(),
      body: jsonEncode({
        'trip_type_id': tripTypeId,
        'title': title,
        'notes': notes,
        'holiday_date': holidayDate,
      }),
    );
    if (res.statusCode != 201) throw Exception('Gagal tambah rencana');
  }

  static Future<void> update(
    int id, {
    required int tripTypeId,
    required String title,
    String? notes,
    String? holidayDate,
  }) async {
    final res = await http.put(
      Uri.parse(ApiConstant.holidayPlanById(id)),
      headers: await _headers(),
      body: jsonEncode({
        'trip_type_id': tripTypeId,
        'title': title,
        'notes': notes,
        'holiday_date': holidayDate,
      }),
    );
    if (res.statusCode != 200) throw Exception('Gagal update rencana');
  }

  static Future<void> delete(int id) async {
    final res = await http.delete(
      Uri.parse(ApiConstant.holidayPlanById(id)),
      headers: await _headers(),
    );
    if (res.statusCode != 200) throw Exception('Gagal hapus rencana');
  }
}
