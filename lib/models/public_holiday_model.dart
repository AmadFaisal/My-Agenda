class PublicHoliday {
  final String date;
  final String localName;
  final String name;
  final String countryCode;
  final List<String> types;

  PublicHoliday({
    required this.date,
    required this.localName,
    required this.name,
    required this.countryCode,
    required this.types,
  });

  factory PublicHoliday.fromJson(Map<String, dynamic> j) => PublicHoliday(
    date: j['date'] ?? '',
    localName: j['localName'] ?? '',
    name: j['name'] ?? '',
    countryCode: j['countryCode'] ?? '',
    types: (j['types'] as List?)?.map((e) => e.toString()).toList() ?? [],
  );
}
