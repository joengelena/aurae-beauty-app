import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shine_app/logic/auth_provider.dart';
import 'package:shine_app/presentation/pages/splash_page.dart';
import 'package:provider/provider.dart';

/// SplashPage Widget Tests
///
/// Note: These tests wait for the full health check cycle to complete using pumpAndSettle.
/// This is necessary because SplashPage starts async health checks in initState.
/// Tests without pumpAndSettle would leave pending timers and fail.
void main() {
  group('SplashPage Widget Tests', () {
    testWidgets('SplashPage eventually shows error state after failed health checks',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => AuthProvider(),
            child: const SplashPage(),
          ),
        ),
      );

      // Wait for health check to fail (will timeout in test environment)
      // This will take up to ~12 seconds (5 retries @ 2 seconds each + timeouts)
      await tester.pumpAndSettle(const Duration(seconds: 15));

      // After all retries fail, error UI should be shown
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(
        find.text(
          'Unable to connect to Aurae servers. Please check your internet connection and try again.',
        ),
        findsOneWidget,
      );

      // Loading indicator should be gone
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // Logo should still be visible
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('SplashPage retry button triggers new health check',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => AuthProvider(),
            child: const SplashPage(),
          ),
        ),
      );

      // Wait for health check to fail
      await tester.pumpAndSettle(const Duration(seconds: 15));

      // Verify error state is shown
      expect(find.text('Retry'), findsOneWidget);

      // Tap retry button
      await tester.tap(find.text('Retry'));
      await tester.pump();

      // Loading state should be shown again
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Welcome to Aurae'), findsOneWidget);

      // Error UI should be hidden
      expect(find.byIcon(Icons.error_outline), findsNothing);

      // Wait for the retry health check to complete to avoid pending timers
      await tester.pumpAndSettle(const Duration(seconds: 15));

      // After retry fails, should be back to error state
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('SplashPage uses correct logo asset',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => AuthProvider(),
            child: const SplashPage(),
          ),
        ),
      );

      // Wait for initial render
      await tester.pumpAndSettle(const Duration(seconds: 15));

      // Find the Image widget
      final imageFinder = find.byType(Image);
      expect(imageFinder, findsOneWidget);

      final imageWidget = tester.widget<Image>(imageFinder);

      // Verify it's using AssetImage
      expect(imageWidget.image, isA<AssetImage>());

      // Get the AssetImage and verify path
      final assetImage = imageWidget.image as AssetImage;
      expect(assetImage.assetName, 'assets/imgs/shine_logo.jpg');
    });

    testWidgets('SplashPage has correct UI structure in error state',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => AuthProvider(),
            child: const SplashPage(),
          ),
        ),
      );

      // Wait for error state
      await tester.pumpAndSettle(const Duration(seconds: 15));

      // Verify scaffold structure
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(SafeArea), findsOneWidget);
      expect(find.byType(Center), findsAtLeastNWidgets(1));

      // Verify error icon styling
      final errorIcon = tester.widget<Icon>(find.byIcon(Icons.error_outline));
      expect(errorIcon.color, Colors.red);
      expect(errorIcon.size, 64);

      // Verify retry button text exists
      expect(find.text('Retry'), findsOneWidget);
    });
  });

  group('SplashPage Component Tests', () {
    test('SplashPage class exists and is a StatefulWidget', () {
      expect(const SplashPage(), isA<StatefulWidget>());
    });
  });

  group('SplashPage Integration Tests', () {
    testWidgets('Full integration test with mocked API',
        (WidgetTester tester) async {
      // This would require a mocked HealthService for complete integration testing
      // Would need dependency injection to properly mock the health service
      //
      // For now, the above tests verify:
      // 1. Error state appears after health check failures
      // 2. Retry button works correctly
      // 3. UI components are rendered properly
      // 4. Logo asset path is correct
    }, skip: true);
  });
}
