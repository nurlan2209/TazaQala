class ReportModel {
  ReportModel({
    required this.id,
    required this.userId,
    required this.district,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.lat,
    required this.lng,
    required this.status,
    required this.createdAt,
    this.assignedTo,
  });

  final String id;
  final String userId;
  final String district;
  final String category;
  final String description;
  final String imageUrl;
  final double lat;
  final double lng;
  final String status;
  final DateTime createdAt;
  final String? assignedTo;

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>? ?? {};
    return ReportModel(
      id: json['_id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      district: json['district'] as String? ?? '',
      category: json['category'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      lat: (location['lat'] as num?)?.toDouble() ?? 0,
      lng: (location['lng'] as num?)?.toDouble() ?? 0,
      status: json['status'] as String? ?? 'new',
      assignedTo: json['assignedTo']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
