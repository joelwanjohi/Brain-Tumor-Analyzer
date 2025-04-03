// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../models/analysis_result.dart';
// import '../services/storage_service.dart';

// class AnalysisScreen extends StatelessWidget {
//   final AnalysisResult analysisResult;
//   final StorageService storageService;

//   const AnalysisScreen({
//     Key? key,
//     required this.analysisResult,
//     required this.storageService,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final dateFormat = DateFormat('MMM d, yyyy - h:mm a');
    
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Analysis Result'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.share),
//             onPressed: () {
//               // TODO: Implement sharing functionality
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('Sharing coming soon')),
//               );
//             },
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // Date and time
//             Text(
//               dateFormat.format(analysisResult.dateTime),
//               style: const TextStyle(
//                 fontSize: 14, 
//                 color: Colors.grey,
//               ),
//               textAlign: TextAlign.right,
//             ),
//             const SizedBox(height: 16),
            
//             // Image preview
//             Container(
//               height: 250,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: Colors.grey),
//               ),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(12),
//                 child: Image.file(
//                   File(analysisResult.imagePath),
//                   fit: BoxFit.contain,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 24),
            
//             // Summary
//             _buildSection(
//               title: 'Summary',
//               content: analysisResult.summary,
//               icon: Icons.summarize,
//               iconColor: Colors.blue,
//             ),
//             const SizedBox(height: 16),
            
//             // Findings
//             _buildSection(
//               title: 'Findings',
//               content: analysisResult.findings,
//               icon: Icons.search,
//               iconColor: Colors.orange,
//             ),
//             const SizedBox(height: 16),
            
//             // Recommendation
//             _buildSection(
//               title: 'Recommendation',
//               content: analysisResult.recommendation,
//               icon: Icons.medical_services,
//               iconColor: Colors.red,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSection({
//     required String title,
//     required String content,
//     required IconData icon,
//     required Color iconColor,
//   }) {
//     return Card(
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(icon, color: iconColor),
//                 const SizedBox(width: 8),
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//             const Divider(),
//             const SizedBox(height: 8),
//             Text(
//               content,
//               style: const TextStyle(fontSize: 16),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }