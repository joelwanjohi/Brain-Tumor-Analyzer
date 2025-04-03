// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../models/analysis_result.dart';
// import '../services/storage_service.dart';
// import 'analysis_screen.dart';

// class SavedAnalysesScreen extends StatefulWidget {
//   final StorageService storageService;

//   const SavedAnalysesScreen({
//     Key? key,
//     required this.storageService,
//   }) : super(key: key);

//   @override
//   State<SavedAnalysesScreen> createState() => _SavedAnalysesScreenState();
// }

// class _SavedAnalysesScreenState extends State<SavedAnalysesScreen> {
//   List<AnalysisResult> _analyses = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadAnalyses();
//   }

//   void _loadAnalyses() {
//     setState(() {
//       _analyses = widget.storageService.getAllAnalysisResults();
//       // Sort by date (newest first)
//       _analyses.sort((a, b) => b.dateTime.compareTo(a.dateTime));
//     });
//   }

//   Future<void> _deleteAnalysis(String id) async {
//     await widget.storageService.deleteAnalysisResult(id);
//     _loadAnalyses();
    
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Analysis deleted')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Saved Analyses'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.delete_sweep),
//             onPressed: _analyses.isEmpty ? null : _showClearAllDialog,
//           ),
//         ],
//       ),
//       body: _analyses.isEmpty
//           ? _buildEmptyState()
//           : ListView.builder(
//               itemCount: _analyses.length,
//               itemBuilder: (context, index) {
//                 final analysis = _analyses[index];
//                 return _buildAnalysisCard(analysis);
//               },
//             ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.analytics_outlined,
//             size: 80,
//             color: Colors.grey[400],
//           ),
//           const SizedBox(height: 16),
//           const Text(
//             'No saved analyses yet',
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             'Analyze an image to see results here',
//             style: TextStyle(fontSize: 16, color: Colors.grey),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAnalysisCard(AnalysisResult analysis) {
//     final dateFormat = DateFormat('MMM d, yyyy - h:mm a');
    
//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: InkWell(
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => AnalysisScreen(
//                 analysisResult: analysis,
//                 storageService: widget.storageService,
//               ),
//             ),
//           );
//         },
//         child: Padding(
//           padding: const EdgeInsets.all(12.0),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Thumbnail
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(8),
//                 child: Image.file(
//                   File(analysis.imagePath),
//                   width: 80,
//                   height: 80,
//                   fit: BoxFit.cover,
//                   errorBuilder: (context, error, stackTrace) {
//                     return Container(
//                       width: 80,
//                       height: 80,
//                       color: Colors.grey[300],
//                       child: const Icon(Icons.broken_image),
//                     );
//                   },
//                 ),
//               ),
//               const SizedBox(width: 16),
              
//               // Content
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       dateFormat.format(analysis.dateTime),
//                       style: const TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       analysis.summary,
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                       style: const TextStyle(fontSize: 16),
//                     ),
//                     const SizedBox(height: 4),
//                     Row(
//                       children: [
//                         const Icon(Icons.medication, size: 16, color: Colors.red),
//                         const SizedBox(width: 4),
//                         Expanded(
//                           child: Text(
//                             analysis.recommendation,
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                             style: const TextStyle(
//                               fontSize: 14,
//                               fontStyle: FontStyle.italic,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
              
//               // Delete button
//               IconButton(
//                 icon: const Icon(Icons.delete_outline, color: Colors.red),
//                 onPressed: () => _showDeleteDialog(analysis.id),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _showDeleteDialog(String id) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Analysis'),
//         content: const Text('Are you sure you want to delete this analysis? This action cannot be undone.'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('CANCEL'),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//               _deleteAnalysis(id);
//             },
//             child: const Text('DELETE', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showClearAllDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Clear All Analyses'),
//         content: const Text('Are you sure you want to delete all saved analyses? This action cannot be undone.'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('CANCEL'),
//           ),
//           TextButton(
//             onPressed: () async {
//               Navigator.of(context).pop();
//               await widget.storageService.clearAllAnalysisResults();
//               _loadAnalyses();
              
//               if (mounted) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('All analyses cleared')),
//                 );
//               }
//             },
//             child: const Text('CLEAR ALL', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }
// }