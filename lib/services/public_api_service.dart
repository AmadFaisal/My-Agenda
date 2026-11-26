import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constant.dart';
import '../models/public_holiday_model.dart';

class PublicApiService {
  static Future<List<PublicHoliday>> fetchHolidays() async {
    final res = await http.get(Uri.parse(ApiConstant.publicHolidays(2026)));
    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List;
      return list.map((e) => PublicHoliday.fromJson(e)).toList();
    }
    throw Exception('Gagal load Public API');
  }
}
