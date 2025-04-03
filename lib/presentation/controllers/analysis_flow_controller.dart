import 'dart:io';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../../models/analysis_result.dart';

class AnalysisFlowController {
  final ApiService apiService;
  final StorageService storageService;

  AnalysisFlowController({
    required this.apiService,
    required this.storageService,
  });

  Future<AnalysisResult> analyzeAndSaveImage(File image) async {
    // Save the image to local storage
    final savedImagePath = await storageService.saveImage(image);
    
    // Create a new file with the saved path
    final savedImage = File(savedImagePath);
    
    // Send image for analysis
    final result = await apiService.analyzeImage(savedImage);
    
    // Save result to storage
    await storageService.saveAnalysisResult(result);
    
    return result;
  }
}
