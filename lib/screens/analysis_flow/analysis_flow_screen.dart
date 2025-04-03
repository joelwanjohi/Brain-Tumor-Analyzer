import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:brain_tumor_analyzer/screens/analysis_flow/analysis_screen.dart';
import 'package:flutter/material.dart';
import '../../presentation/controllers/analysis_flow_controller.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';

class AnalysisFlowScreen extends StatefulWidget {
  final File image;
  final ApiService apiService;
  final StorageService storageService;
  final VoidCallback onAnalysisComplete;

  const AnalysisFlowScreen({
    Key? key,
    required this.image,
    required this.apiService,
    required this.storageService,
    required this.onAnalysisComplete,
  }) : super(key: key);

  @override
  State<AnalysisFlowScreen> createState() => _AnalysisFlowScreenState();
}

class _AnalysisFlowScreenState extends State<AnalysisFlowScreen> with SingleTickerProviderStateMixin {
  late final AnalysisFlowController _controller;
  late AnimationController _stageController;
  int _currentStage = 0;
  
  final List<String> _stages = [
    "Processing image...",
    "Detecting features...",
    "Running neural network...",
    "Generating results..."
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnalysisFlowController(
      apiService: widget.apiService,
      storageService: widget.storageService,
    );
    
    _stageController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    
    _stageController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (_currentStage < _stages.length - 1) {
          setState(() {
            _currentStage++;
          });
          _stageController.reset();
          _stageController.forward();
        }
      }
    });
    
    _stageController.forward();
    _analyzeImage();
  }

  @override
  void dispose() {
    _stageController.dispose();
    super.dispose();
  }

  Future<void> _analyzeImage() async {
    try {
      final result = await _controller.analyzeAndSaveImage(widget.image);
      
      if (mounted) {
        // Call the callback to refresh the home screen list
        widget.onAnalysisComplete();
        
        // Navigate to analysis screen and replace current screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AnalysisScreen(
              analysisResult: result,
              storageService: widget.storageService,
              onDelete: (_) {
                // Call onAnalysisComplete to refresh the list on deletion
                widget.onAnalysisComplete();
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error analyzing image: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Go back to home screen
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Analyzing Brain Scan'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.green.withOpacity(0.8),
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: Stack(
          children: [
            // Background with blur effect
            Positioned.fill(
              child: ClipRRect(
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Opacity(
                    opacity: 0.15,
                    child: Image.file(
                      widget.image,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            
            // Content
            SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 1),
                  
                  // Brain scan animation
                  _buildBrainAnimation(),
                  
                  const Spacer(flex: 1),
                  
                  // Image preview
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 5,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.file(
                        widget.image,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  
                  const Spacer(flex: 1),
                  
                  // Status text
                  const Text(
                    "Analyzing brain scan with AI...",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Progress stages
                  _buildProgressStages(),
                  
                  const Spacer(flex: 1),
                  
                  // Bottom note
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.green.withOpacity(0.2),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: Colors.green,
                          size: 20,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "This may take a moment.",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrainAnimation() {
    return SizedBox(
      height: 120,
      child: _buildCustomBrainAnimation(),
    );
  }

  Widget _buildCustomBrainAnimation() {
    return LoadingBrainAnimation(
      size: 120,
      color: Colors.green,
    );
  }

  Widget _buildProgressStages() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Column(
        children: [
          Text(
            _stages[_currentStage],
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: _stageController,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: _stageController.value,
                backgroundColor: Colors.grey.withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                borderRadius: BorderRadius.circular(10),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Custom brain animation
class LoadingBrainAnimation extends StatefulWidget {
  final double size;
  final Color color;
  
  const LoadingBrainAnimation({
    Key? key,
    this.size = 100,
    this.color = Colors.green,
  }) : super(key: key);

  @override
  State<LoadingBrainAnimation> createState() => _LoadingBrainAnimationState();
}

class _LoadingBrainAnimationState extends State<LoadingBrainAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Pulse effect
            Container(
              width: widget.size * _pulseAnimation.value,
              height: widget.size * _pulseAnimation.value,
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
            
            // Center brain icon
            Container(
              width: widget.size * 0.7,
              height: widget.size * 0.7,
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.psychology_rounded,
                size: widget.size * 0.4,
                color: widget.color,
              ),
            ),
            
            // Orbiting particles
            ...List.generate(6, (index) {
              final angle = index * (3.14159 * 2 / 6) + _controller.value * 2 * 3.14159;
              final x = widget.size * 0.4 * cos(angle);
              final y = widget.size * 0.4 * sin(angle);
              
              return Transform.translate(
                offset: Offset(x, y),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}