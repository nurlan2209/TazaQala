import 'dart:io';
import 'package:dio/dio.dart';
import '../models/district_stat.dart';
import '../models/report.dart';
import 'api_service.dart';

class ReportService {
  ReportService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  Future<List<ReportModel>> fetchReports({String? district}) async {
    final response = await _apiService.get(
      '/reports/all',
      queryParameters: district != null ? {'district': district} : null,
    );

    final data = response.data as List<dynamic>;
    return data.map((item) => ReportModel.fromJson(item)).toList();
  }

  Future<List<ReportModel>> fetchMyReports() async {
    final response = await _apiService.get('/reports/mine');
    final data = response.data as List<dynamic>;
    return data.map((item) => ReportModel.fromJson(item)).toList();
  }

  Future<ReportModel> createReport({
    required String category,
    required String description,
    required double lat,
    required double lng,
    required File image,
    String? districtOverride,
  }) async {
    final fileName = image.path.split('/').last;
    final formData = FormData.fromMap({
      'category': category,
      'description': description,
      'lat': lat,
      'lng': lng,
      if (districtOverride != null) 'district': districtOverride,
      'image': await MultipartFile.fromFile(image.path, filename: fileName),
    });

    final response = await _apiService.post(
      '/reports/create',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    return ReportModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ReportModel> updateReport({
    required String id,
    String? category,
    String? description,
    String? status,
    double? lat,
    double? lng,
    String? assignedTo,
  }) async {
    final payload = <String, dynamic>{};
    if (category != null) payload['category'] = category;
    if (description != null) payload['description'] = description;
    if (status != null) payload['status'] = status;
    if (assignedTo != null) payload['assignedTo'] = assignedTo;
    if (lat != null && lng != null) {
      payload['lat'] = lat;
      payload['lng'] = lng;
    }

    final response = await _apiService.patch(
      '/reports/update/$id',
      data: payload,
    );

    return ReportModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<DistrictStat>> fetchDistrictStats() async {
    final response = await _apiService.get('/reports/stats/districts');
    final data = response.data as List<dynamic>;
    return data.map((item) => DistrictStat.fromJson(item)).toList();
  }
}
