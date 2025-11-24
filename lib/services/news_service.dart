import 'package:flutter/foundation.dart';
import '../models/news.dart';
import 'api_service.dart';
import '../utils/constans.dart';

class NewsService {
  NewsService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  Future<List<NewsItem>> fetchNews() async {
    try {
      final response = await _apiService.get(
        '/news',
      );
      final data = response.data as List<dynamic>;
      // ignore: avoid_print
      print('NewsService.fetchNews success, count=${data.length}');
      final items = data.map((item) => NewsItem.fromJson(item)).toList();
      _rewriteImagesForWeb(items);
      if (kIsWeb) {
        // ensure url present for local news if image proxied
        for (var i = 0; i < items.length; i++) {
          if (items[i].url == null && items[i].imageUrl != null) {
            items[i] = NewsItem(
              id: items[i].id,
              title: items[i].title,
              description: items[i].description,
              district: items[i].district,
              imageUrl: items[i].imageUrl,
              url: items[i].url,
              isPublished: items[i].isPublished,
              publishedAt: items[i].publishedAt,
            );
          }
        }
      }
      if (items.isNotEmpty) return items;

      final fallback = await _fetchAstanaNews();
      // ignore: avoid_print
      print('NewsService.fetchNews fallback astana count=${fallback.length}');
      return fallback;
    } catch (e) {
      // ignore: avoid_print
      print('NewsService.fetchNews error: $e');
      rethrow;
    }
  }

  Future<List<NewsItem>> _fetchAstanaNews() async {
    try {
      final response = await _apiService.get('/astana-news');
      final data = response.data as List<dynamic>;
      return data.map((item) {
        final map = item as Map<String, dynamic>;
        final safeImage = _proxyImageIfWeb(map['image'] as String?);
        return NewsItem(
          id: (map['url'] as String? ?? map['title'] as String? ?? '').hashCode.toString(),
          title: map['title'] as String? ?? '',
          description: map['description'] as String? ?? '',
          district: 'Астана',
          imageUrl: safeImage,
          url: map['url'] as String?,
          isPublished: true,
          publishedAt: DateTime.now(),
        );
      }).toList();
    } catch (e) {
      // ignore: avoid_print
      print('NewsService._fetchAstanaNews error: $e');
      return [];
    }
  }

  Future<NewsItem> createNews({
    required String title,
    required String description,
    String? imageUrl,
    bool isPublished = true,
  }) async {
    final response = await _apiService.post('/news', data: {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'isPublished': isPublished,
    });
    return NewsItem.fromJson(response.data as Map<String, dynamic>);
  }

  Future<NewsItem> updateNews({
    required String id,
    String? title,
    String? description,
    String? imageUrl,
    bool? isPublished,
  }) async {
    final payload = <String, dynamic>{};
    if (title != null) payload['title'] = title;
    if (description != null) payload['description'] = description;
    if (imageUrl != null) payload['imageUrl'] = imageUrl;
    if (isPublished != null) payload['isPublished'] = isPublished;

    final response = await _apiService.patch(
      '/news/$id',
      data: payload,
    );
    return NewsItem.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteNews(String id) async {
    await _apiService.delete('/news/$id');
  }

  void _rewriteImagesForWeb(List<NewsItem> items) {
    if (!kIsWeb) return;
    for (var i = 0; i < items.length; i++) {
      final proxied = _proxyImageIfWeb(items[i].imageUrl);
      if (proxied != items[i].imageUrl) {
        items[i] = NewsItem(
          id: items[i].id,
          title: items[i].title,
          description: items[i].description,
          district: items[i].district,
          imageUrl: proxied,
          isPublished: items[i].isPublished,
          publishedAt: items[i].publishedAt,
        );
      }
    }
  }

  String? _proxyImageIfWeb(String? url) {
    if (!kIsWeb || url == null || url.isEmpty) return url;
    if (url.startsWith('http')) {
      final encoded = Uri.encodeComponent(url);
      return '$apiBaseUrl/proxy?url=$encoded';
    }
    return url;
  }
}
