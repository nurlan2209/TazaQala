class DistrictStat {
  DistrictStat({
    required this.district,
    required this.total,
    required this.statusCounts,
  });

  final String district;
  final int total;
  final Map<String, int> statusCounts;

  factory DistrictStat.fromJson(Map<String, dynamic> json) {
    final statusMap = <String, int>{};
    final rawStatus = json['statusCounts'] as Map<String, dynamic>? ?? {};
    rawStatus.forEach((key, value) {
      statusMap[key] = (value as num?)?.toInt() ?? 0;
    });

    return DistrictStat(
      district: json['district'] as String? ?? '',
      total: (json['total'] as num?)?.toInt() ?? 0,
      statusCounts: statusMap,
    );
  }
}
