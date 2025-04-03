import 'package:brain_tumor_analyzer/models/analysis_result.dart';
import 'package:brain_tumor_analyzer/presentation/controllers/saved_analyses_controller.dart';
import 'package:brain_tumor_analyzer/presentation/widgets/analysis_result_card.dart';
import 'package:brain_tumor_analyzer/screens/analysis_flow/analysis_screen.dart';
import 'package:brain_tumor_analyzer/services/storage_service.dart';
import 'package:flutter/material.dart';


class SavedAnalysesScreen extends StatefulWidget {
  final StorageService storageService;

  const SavedAnalysesScreen({
    Key? key,
    required this.storageService,
  }) : super(key: key);

  @override
  State<SavedAnalysesScreen> createState() => _SavedAnalysesScreenState();
}

class _SavedAnalysesScreenState extends State<SavedAnalysesScreen> {
  List<AnalysisResult> _analyses = [];
  late final SavedAnalysesController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SavedAnalysesController(storageService: widget.storageService);
    _loadAnalyses();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload analyses when screen gets focus
    _loadAnalyses();
  }

  void _loadAnalyses() {
    setState(() {
      _analyses = _controller.getAllAnalyses();
    });
  }

  // Handle immediate deletion from the list
  void _handleDeletion(String id) {
    setState(() {
      _analyses.removeWhere((analysis) => analysis.id == id);
    });
  }

  Future<void> _deleteAnalysis(String id) async {
    await _controller.deleteAnalysis(id);
    
    // Update the UI immediately
    setState(() {
      _analyses.removeWhere((analysis) => analysis.id == id);
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Analysis deleted')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Analyses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: _analyses.isEmpty ? null : _showClearAllDialog,
          ),
        ],
      ),
      body: _analyses.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              itemCount: _analyses.length,
              itemBuilder: (context, index) {
                final analysis = _analyses[index];
                return AnalysisResultCard(
                  analysisResult: analysis,
                  onTap: () => _navigateToAnalysisDetails(analysis),
                  onDelete: () => _showDeleteDialog(analysis.id),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'No saved analyses yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Analyze an image to see results here',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _navigateToAnalysisDetails(AnalysisResult analysis) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnalysisScreen(
          analysisResult: analysis,
          storageService: widget.storageService,
          onDelete: _handleDeletion, // Pass the deletion handler
        ),
      ),
    ).then((_) {
      // Also refresh when returning to ensure consistency
      _loadAnalyses();
    });
  }

  void _showDeleteDialog(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Analysis'),
        content: const Text('Are you sure you want to delete this analysis? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteAnalysis(id);
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Analyses'),
        content: const Text('Are you sure you want to delete all saved analyses? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _controller.clearAllAnalyses();
              _loadAnalyses();
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All analyses cleared')),
                );
              }
            },
            child: const Text('CLEAR ALL', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}