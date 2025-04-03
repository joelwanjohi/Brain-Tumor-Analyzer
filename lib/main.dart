import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/analysis_result.dart';
import 'services/api_service.dart';
import 'services/storage_service.dart';
import 'screens/home/home_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'presentation/controllers/home_controller.dart';

// Global key for Navigator state
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register the adapter
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(AnalysisResultAdapter());
  }
  
  // Initialize services
  final storageService = StorageService();
  await storageService.init();
  
  // API Service with your Flask server URL
  final apiService = ApiService(baseUrl: 'http://10.5.56.233:5000');
  
  // Create the controller for the home screen
  final homeController = HomeController(
    apiService: apiService,
    storageService: storageService,
  );
  
// Check if it's first launch
final prefs = await SharedPreferences.getInstance();

// TEMPORARY: Force reset onboarding status
await prefs.setBool('has_seen_onboarding', false);

final bool hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
  
// Debug print to confirm the value
print("DEBUG: Has seen onboarding: $hasSeenOnboarding");
  
  runApp(BrainTumorAnalyzerApp(
    homeController: homeController,
    hasSeenOnboarding: hasSeenOnboarding,
  ));
}

class BrainTumorAnalyzerApp extends StatelessWidget {
  final HomeController homeController;
  final bool hasSeenOnboarding;

  const BrainTumorAnalyzerApp({
    Key? key,
    required this.homeController,
    required this.hasSeenOnboarding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brain Tumor Analyzer',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: hasSeenOnboarding 
          ? HomeScreen(controller: homeController)
          : OnboardingScreen(homeController: homeController),
    );
  }
}

//from flask_cors import CORS   CORS(app) flask-cors>=5.0.0