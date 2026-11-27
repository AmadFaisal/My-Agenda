import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constant.dart';
import '../models/public_holiday_model.dart';

class PublicApiService {
  static Future<List<PublicHoliday>> fetchHolidays({int? year}) async {
    final requestedYear = year ?? DateTime.now().year;
    final res = await http.get(
      Uri.parse(ApiConstant.publicHolidays(requestedYear)),
    );
    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List;
      return list.map((e) => PublicHoliday.fromJson(e)).toList();
    }
    throw Exception('Gagal load Public API');
  }
}
