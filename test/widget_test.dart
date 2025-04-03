// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:brain_tumor_analyzer/presentation/controllers/home_controller.dart';
import 'package:brain_tumor_analyzer/services/api_service.dart';
import 'package:brain_tumor_analyzer/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:brain_tumor_analyzer/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Create services
    final apiService = ApiService(baseUrl: 'http://10.5.56.233:5000');
    final storageService = StorageService();
    
    // Create controller
    final homeController = HomeController(
      apiService: apiService,
      storageService: storageService,
    );
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(BrainTumorAnalyzerApp(
      homeController: homeController,
        hasSeenOnboarding: false,
    ));


    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}