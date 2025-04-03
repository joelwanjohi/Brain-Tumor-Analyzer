import 'dart:io';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../models/analysis_result.dart';
import 'package:logger/logger.dart';

class StorageService {
  static const String analysisBoxName = 'analysis_results';
  final Logger logger = Logger();
  late Box<AnalysisResult> _analysisBox;
  
  Future<void> init() async {
    // Don't initialize Hive here, it's already initialized in main.dart
    
    // Don't register adapters here, they're already registered in main.dart
    
    // Open boxes
    _analysisBox = await Hive.openBox<AnalysisResult>(analysisBoxName);
    
    logger.i('Storage service initialized with ${_analysisBox.length} saved analyses');
  }
  
  Future<String> saveImage(File imageFile) async {
    final appDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${appDir.path}/images');
    
    // Create images directory if it doesn't exist
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }
    
    // Generate a timestamp-based filename
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filename = 'image_$timestamp.jpg';
    final savedImagePath = '${imagesDir.path}/$filename';
    
    // Copy the image to the app's documents directory
    await imageFile.copy(savedImagePath);
    logger.i('Image saved to: $savedImagePath');
    
    return savedImagePath;
  }
  
  Future<void> saveAnalysisResult(AnalysisResult result) async {
    await _analysisBox.put(result.id, result);
    logger.i('Analysis result saved with id: ${result.id}');
  }
  
  List<AnalysisResult> getAllAnalysisResults() {
    return _analysisBox.values.toList();
  }
  
  Future<AnalysisResult?> getAnalysisResult(String id) async {
    return _analysisBox.get(id);
  }
  
  Future<void> deleteAnalysisResult(String id) async {
    await _analysisBox.delete(id);
    logger.i('Analysis result deleted with id: $id');
  }
  
  Future<void> clearAllAnalysisResults() async {
    await _analysisBox.clear();
    logger.w('All analysis results cleared');
  }
}