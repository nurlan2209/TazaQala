import '../models/ai_insight.dart';
import 'api_service.dart';

class AiService {
  AiService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  Future<AiInsights> fetchInsights() async {
    final response = await _apiService.get('/reports/insights/ai');
    return AiInsights.fromJson(response.data as Map<String, dynamic>);
  }
}
