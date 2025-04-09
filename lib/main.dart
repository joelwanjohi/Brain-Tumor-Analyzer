import 'package:brain_tumor_analyzer/screens/home/patient_home_screen.dart';
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
  
  // Check if it's first launch and get role
  final prefs = await SharedPreferences.getInstance();

  // TEMPORARY: Force reset onboarding status (comment out in production)
  // await prefs.setBool('has_seen_onboarding', false);

  final bool hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
  final String? userRole = prefs.getString('user_role');
  
  // Debug print to confirm the values
  print("DEBUG: Has seen onboarding: $hasSeenOnboarding");
  print("DEBUG: User role: $userRole");
  
  runApp(BrainTumorAnalyzerApp(
    homeController: homeController,
    hasSeenOnboarding: hasSeenOnboarding,
    userRole: userRole,
  ));
}

class BrainTumorAnalyzerApp extends StatelessWidget {
  final HomeController homeController;
  final bool hasSeenOnboarding;
  final String? userRole;

  const BrainTumorAnalyzerApp({
    Key? key,
    required this.homeController,
    required this.hasSeenOnboarding,
    required this.userRole,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brain Tumor Analyzer',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: ThemeData(
        primarySwatch: Colors.green,
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
      home: _getInitialScreen(),
      routes: {
        '/home': (context) => HomeScreen(controller: homeController),
        '/patient': (context) => PatientHomeScreen(controller: homeController),
        '/onboarding': (context) => OnboardingScreen(homeController: homeController),
      },
    );
  }
  
Widget _getInitialScreen() {
  // Show onboarding if either it hasn't been seen OR no role has been selected
  if (!hasSeenOnboarding || userRole == null) {
    return OnboardingScreen(homeController: homeController);
  }
  
  // Then route based on user role (which should now never be null)
  if (userRole == 'patient') {
    return PatientHomeScreen(controller: homeController);
  } else {
    // Default to doctor mode
    return HomeScreen(controller: homeController);
  }
}
}