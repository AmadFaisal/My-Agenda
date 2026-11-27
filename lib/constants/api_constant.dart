class ApiConstant {
  // Karena kita jalan di Chrome, kita pakai localhost (bukan 10.0.2.2)
  static const String baseUrlLaravel = "http://10.10.11.237:8000/api";
  static const String publicApiUrl = "https://date.nager.at/api/v3";

  // Auth
  static const String register = "$baseUrlLaravel/register";
  static const String login = "$baseUrlLaravel/login";
  static const String user = "$baseUrlLaravel/user";
  static const String logout = "$baseUrlLaravel/logout";

  // Trip Types (Tabel 1)
  static const String tripTypes = "$baseUrlLaravel/trip-types";
  static String tripTypeById(int id) => "$baseUrlLaravel/trip-types/$id";

  // Holiday Plans (Tabel 2)
  static const String holidayPlans = "$baseUrlLaravel/holiday-plans";
  static String holidayPlanById(int id) => "$baseUrlLaravel/holiday-plans/$id";

  // Public API
  static String publicHolidays(int year) =>
      "$publicApiUrl/PublicHolidays/$year/ID";
}
