class NewsItem {
  NewsItem({
    required this.id,
    required this.title,
    required this.description,
    required this.district,
    this.imageUrl,
    this.url,
    required this.isPublished,
    required this.publishedAt,
  });

  final String id;
  final String title;
  final String description;
  final String district;
  final String? imageUrl;
  final String? url;
  final bool isPublished;
  final DateTime publishedAt;

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'] ?? json['_id'];
    return NewsItem(
      id: rawId?.toString() ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      district: json['district'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      url: json['url'] as String?,
      isPublished: json['isPublished'] as bool? ?? true,
      publishedAt: DateTime.tryParse(json['publishedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'district': district,
        'imageUrl': imageUrl,
        'url': url,
        'isPublished': isPublished,
        'publishedAt': publishedAt.toIso8601String(),
      };
}
