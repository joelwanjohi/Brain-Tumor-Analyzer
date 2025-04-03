import '../../services/storage_service.dart';
import '../../models/analysis_result.dart';

class SavedAnalysesController {
  final StorageService storageService;

  SavedAnalysesController({
    required this.storageService,
  });

  List<AnalysisResult> getAllAnalyses() {
    final analyses = storageService.getAllAnalysisResults();
    // Sort by date (newest first)
    analyses.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return analyses;
  }

  Future<void> deleteAnalysis(String id) async {
    await storageService.deleteAnalysisResult(id);
  }

  Future<void> clearAllAnalyses() async {
    await storageService.clearAllAnalysisResults();
  }
}