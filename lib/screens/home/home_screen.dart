// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import '../../services/api_service.dart';
// import '../../services/storage_service.dart';
// import '../../models/analysis_result.dart';
// import '../analysis_screen.dart';
// import '../saved_analyses_screen.dart';
// import '../../widgets/image_picker_widget.dart';

// class HomeScreen extends StatefulWidget {
//   final ApiService apiService;
//   final StorageService storageService;

//   const HomeScreen({
//     Key? key,
//     required this.apiService,
//     required this.storageService,
//   }) : super(key: key);

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   File? _selectedImage;
//   bool _isAnalyzing = false;

//   void _setImage(File? image) {
//     setState(() {
//       _selectedImage = image;
//     });
//   }

//   Future<void> _analyzeImage() async {
//     if (_selectedImage == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please select an image first')),
//       );
//       return;
//     }

//     setState(() {
//       _isAnalyzing = true;
//     });

//     try {
//       // Save the image to local storage
//       final savedImagePath = await widget.storageService.saveImage(_selectedImage!);
      
//       // Create a new file with the saved path
//       final savedImage = File(savedImagePath);
      
//       // Send image for analysis
//       final result = await widget.apiService.analyzeImage(savedImage);
      
//       // Save result to Hive
//       await widget.storageService.saveAnalysisResult(result);
      
//       if (mounted) {
//         // Navigate to analysis screen
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => AnalysisScreen(
//               analysisResult: result,
//               storageService: widget.storageService,
//             ),
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error analyzing image: $e')),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isAnalyzing = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Brain Tumor Analyzer'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.history),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => SavedAnalysesScreen(
//                     storageService: widget.storageService,
//                   ),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Expanded(
//               child: ImagePickerWidget(
//                 image: _selectedImage,
//                 onImageSelected: _setImage,
//               ),
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: _isAnalyzing ? null : _analyzeImage,
//               style: ElevatedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//               ),
//               child: _isAnalyzing
//                   ? const Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         SizedBox(
//                           width: 24,
//                           height: 24,
//                           child: CircularProgressIndicator(color: Colors.white),
//                         ),
//                         SizedBox(width: 16),
//                         Text('Analyzing...')
//                       ],
//                     )
//                   : const Text('Analyze Image'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:io';
import 'package:brain_tumor_analyzer/screens/analysis_flow/analysis_screen.dart';
import 'package:flutter/material.dart';
import '../../presentation/controllers/home_controller.dart';
import '../../presentation/widgets/empty_analysis_state.dart';
import '../../presentation/widgets/analysis_card.dart';
import '../../models/analysis_result.dart';
import '../analysis_flow/analysis_flow_screen.dart';

class HomeScreen extends StatefulWidget {
  final HomeController controller;

  const HomeScreen({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<AnalysisResult> _analyses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnalyses();
  }

  @override
  void didChangeDependencies() {
    _loadAnalyses();
    super.didChangeDependencies();
  }

  Future<void> _loadAnalyses() async {
    setState(() {
      _isLoading = true;
    });

    final analyses = await widget.controller.getAllAnalyses();
    
    setState(() {
      _analyses = analyses;
      _isLoading = false;
    });
  }

  // Handler for when an analysis is deleted
  void _handleAnalysisDeleted(String deletedId) {
    setState(() {
      _analyses.removeWhere((analysis) => analysis.id == deletedId);
    });
    _loadAnalyses();
  }

  Future<void> _pickAndAnalyzeImage() async {
    final source = await widget.controller.showImageSourceDialog(context);
    
    if (source == null) return;

    try {
      final File? image = await widget.controller.pickImage(source);
      
      if (image == null || !mounted) return;
      
      _navigateToAnalysisFlow(image);
    } catch (e) {
      if (!mounted) return;
      widget.controller.showErrorSnackBar(context, 'Error picking image: $e');
    }
  }

  void _navigateToAnalysisFlow(File image) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnalysisFlowScreen(
          image: image,
          apiService: widget.controller.apiService,
          storageService: widget.controller.storageService,
          onAnalysisComplete: _loadAnalyses,
        ),
      ),
    );
  }

  void _navigateToAnalysisDetails(AnalysisResult result) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnalysisScreen(
          analysisResult: result,
          storageService: widget.controller.storageService,
          onDelete: _handleAnalysisDeleted, // Pass the delete handler
        ),
      ),
    ).then((_) {
      // Refresh the list when returning from details screen
      _loadAnalyses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Your Saved Analyses'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.green,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickAndAnalyzeImage,
        elevation: 4,
        tooltip: 'Upload Brain Scan',
        backgroundColor: Colors.green,
        child: const Icon(Icons.add,color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _analyses.isEmpty
              ? EmptyAnalysisState(onUploadPressed: _pickAndAnalyzeImage)
              : _buildAnalysesList(),
    );
  }

  Widget _buildAnalysesList() {
    return RefreshIndicator(
      onRefresh: _loadAnalyses,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: _analyses.length,
          itemBuilder: (context, index) {
            final analysis = _analyses[index];
            return AnalysisCard(
              analysis: analysis, 
              onTap: () => _navigateToAnalysisDetails(analysis)
            );
          },
        ),
      ),
    );
  }
}