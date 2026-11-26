class TripTypeModel {
  final int id;
  final String name;
  TripTypeModel({required this.id, required this.name});
  factory TripTypeModel.fromJson(Map<String, dynamic> j) =>
      TripTypeModel(id: j['id'], name: j['name']);
}
