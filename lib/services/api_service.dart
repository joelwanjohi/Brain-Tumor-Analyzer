import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../models/analysis_result.dart';

class ApiService {
  final String baseUrl;
  final Logger logger = Logger();
  final Dio _dio = Dio();

  ApiService({required this.baseUrl}) {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  Future<AnalysisResult> analyzeImage(File imageFile) async {
    try {
      // Create multipart request
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      // Send request to the analyze endpoint
      final response = await _dio.post('/analyze', data: formData);

      if (response.statusCode == 200) {
        logger.i('Image analysis successful');
        
        // Parse the response
        Map<String, dynamic> data = response.data;
        String resultString = data['result'];
        Map<String, dynamic> resultJson = json.decode(resultString);
        
        // Create and return analysis result
        return AnalysisResult.fromJson(resultJson, imageFile.path);
      } else {
        logger.e('Image analysis failed with status: ${response.statusCode}');
        throw Exception('Failed to analyze image: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Error analyzing image: $e');
      throw Exception('Error analyzing image: $e');
    }
  }
}