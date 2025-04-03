import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/analysis_result.dart';
import '../../services/storage_service.dart';
import '../../presentation/widgets/analysis_section.dart';
import '../../presentation/controllers/saved_analyses_controller.dart';

class AnalysisScreen extends StatelessWidget {
  final AnalysisResult analysisResult;
  final StorageService storageService;
  final Function(String) onDelete; // New callback with the ID parameter

  const AnalysisScreen({
    Key? key,
    required this.analysisResult,
    required this.storageService,
    required this.onDelete, // Make it required
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy - h:mm a');
    final controller = SavedAnalysesController(storageService: storageService);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis Result'),
         backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Date and time
            Text(
              dateFormat.format(analysisResult.dateTime),
              style: const TextStyle(
                fontSize: 14, 
                color: Colors.grey,
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 16),
            
            // Image preview
            Container(
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(analysisResult.imagePath),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Summary
            AnalysisSection(
              title: 'Summary',
              content: analysisResult.summary,
              icon: Icons.summarize,
              iconColor: Colors.blue,
            ),
            const SizedBox(height: 16),
            
            // Findings
            AnalysisSection(
              title: 'Findings',
              content: analysisResult.findings,
              icon: Icons.search,
              iconColor: Colors.orange,
            ),
            const SizedBox(height: 16),
            
            // Recommendation
            AnalysisSection(
              title: 'Recommendation',
              content: analysisResult.recommendation,
              icon: Icons.medical_services,
              iconColor: Colors.red,
            ),
            
            const SizedBox(height: 32),
            
            // Delete button placed below the results
            ElevatedButton.icon(
              onPressed: () => _showDeleteConfirmation(context, controller),
              icon: const Icon(Icons.delete),
              label: const Text('DELETE'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, SavedAnalysesController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Analysis'),
        content: const Text(
          'Are you sure you want to delete this analysis? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () async {
              // Close the dialog
              Navigator.of(context).pop();
              
              try {
                // Delete the analysis using the controller
                await controller.deleteAnalysis(analysisResult.id);
                
                // Call the parent screen's onDelete callback with the ID
                onDelete(analysisResult.id);
                
                // Show success message
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Analysis deleted')),
                  );
                  
                  // Go back to previous screen
                  Navigator.of(context).pop();
                }
              } catch (e) {
                // Show error message if deletion fails
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting analysis: $e')),
                  );
                }
              }
            },
            child: const Text(
              'DELETE', 
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}