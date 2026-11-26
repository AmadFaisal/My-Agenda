class HolidayPlanModel {
  final int id;
  final int tripTypeId;
  final String title;
  final String? notes;
  final String? holidayDate;
  final String? tripTypeName;

  HolidayPlanModel({
    required this.id,
    required this.tripTypeId,
    required this.title,
    this.notes,
    this.holidayDate,
    this.tripTypeName,
  });

  factory HolidayPlanModel.fromJson(Map<String, dynamic> j) => HolidayPlanModel(
    id: j['id'],
    tripTypeId: j['trip_type_id'],
    title: j['title'],
    notes: j['notes'],
    holidayDate: j['holiday_date'],
    // Ambil nama trip type dari relasi
    tripTypeName: j['trip_type'] != null ? j['trip_type']['name'] : null,
  );
}
