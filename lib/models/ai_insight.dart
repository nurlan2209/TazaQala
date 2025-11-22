class AiInsights {
  AiInsights({
    required this.stats,
    required this.recommendations,
    this.summary,
  });

  final AiStats stats;
  final List<AiRecommendation> recommendations;
  final String? summary;

  factory AiInsights.fromJson(Map<String, dynamic> json) {
    return AiInsights(
      stats: AiStats.fromJson(json['stats'] as Map<String, dynamic>? ?? {}),
      summary: json['summary'] as String?,
      recommendations: (json['recommendations'] as List<dynamic>? ?? [])
          .map((item) => AiRecommendation.fromJson(item))
          .toList(),
    );
  }
}

class AiStats {
  AiStats({
    required this.highPriority,
    required this.mediumPriority,
    required this.totalReports,
    required this.resolved,
    required this.unresolved,
    required this.accuracy,
    required this.monthlyGrowth,
    required this.topCategories,
  });

  final int highPriority;
  final int mediumPriority;
  final int totalReports;
  final int resolved;
  final int unresolved;
  final int accuracy;
  final int monthlyGrowth;
  final List<CategoryCount> topCategories;

  factory AiStats.fromJson(Map<String, dynamic> json) {
    return AiStats(
      highPriority: (json['highPriority'] as num?)?.toInt() ?? 0,
      mediumPriority: (json['mediumPriority'] as num?)?.toInt() ?? 0,
      totalReports: (json['totalReports'] as num?)?.toInt() ?? 0,
      resolved: (json['resolved'] as num?)?.toInt() ?? 0,
      unresolved: (json['unresolved'] as num?)?.toInt() ?? 0,
      accuracy: (json['accuracy'] as num?)?.toInt() ?? 0,
      monthlyGrowth: (json['monthlyGrowth'] as num?)?.toInt() ?? 0,
      topCategories: (json['topCategories'] as List<dynamic>? ?? [])
          .map((e) => CategoryCount.fromJson(e as Map<String, dynamic>? ?? {}))
          .toList(),
    );
  }
}

class CategoryCount {
  CategoryCount({required this.category, required this.count});

  final String category;
  final int count;

  factory CategoryCount.fromJson(Map<String, dynamic> json) {
    return CategoryCount(
      category: json['category'] as String? ?? 'Жалпы',
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }
}

class AiRecommendation {
  AiRecommendation({
    required this.id,
    required this.level,
    required this.category,
    required this.title,
    required this.description,
    required this.action,
  });

  final String id;
  final String level;
  final String category;
  final String title;
  final String description;
  final String action;

  factory AiRecommendation.fromJson(Map<String, dynamic> json) {
    return AiRecommendation(
      id: json['id']?.toString() ?? '',
      level: json['level'] as String? ?? 'info',
      category: json['category'] as String? ?? 'Жалпы',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      action: json['action'] as String? ?? '',
    );
  }
}
