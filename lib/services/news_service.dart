import '../models/news.dart';
import 'api_service.dart';

class NewsService {
  NewsService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  Future<List<NewsItem>> fetchNews({String? district}) async {
    final response = await _apiService.get(
      '/news',
      queryParameters: district != null ? {'district': district} : null,
    );
    final data = response.data as List<dynamic>;
    return data.map((item) => NewsItem.fromJson(item)).toList();
  }

  Future<NewsItem> createNews({
    required String title,
    required String description,
    required String district,
    String? imageUrl,
    bool isPublished = true,
  }) async {
    final response = await _apiService.post('/news', data: {
      'title': title,
      'description': description,
      'district': district,
      'imageUrl': imageUrl,
      'isPublished': isPublished,
    });
    return NewsItem.fromJson(response.data as Map<String, dynamic>);
  }

  Future<NewsItem> updateNews({
    required String id,
    String? title,
    String? description,
    String? district,
    String? imageUrl,
    bool? isPublished,
  }) async {
    final payload = <String, dynamic>{};
    if (title != null) payload['title'] = title;
    if (description != null) payload['description'] = description;
    if (district != null) payload['district'] = district;
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
}
