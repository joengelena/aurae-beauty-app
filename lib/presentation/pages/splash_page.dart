import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shine_app/data/services/health_service.dart';
import 'package:shine_app/logic/auth_provider.dart';
import 'package:provider/provider.dart';

/// Splash screen that performs health check before navigating to the app
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final HealthService _healthService = HealthService();
  bool _showError = false;
  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();
    _performHealthCheck();
  }

  /// Perform health check with retry logic
  Future<void> _performHealthCheck() async {
    setState(() {
      _showError = false;
      _isRetrying = true;
    });

    // Perform health check with retries (10 attempts, 2 seconds between each)
    final isHealthy = await _healthService.checkHealthWithRetry(
      maxRetries: 10,
      retryDelay: const Duration(seconds: 2),
      timeout: const Duration(seconds: 20),
    );

    if (!mounted) return;

    if (isHealthy) {
      // Health check passed - check auth status and navigate
      await _checkAuthAndNavigate();
    } else {
      // Health check failed after all retries - show error
      setState(() {
        _showError = true;
        _isRetrying = false;
      });
    }
  }

  /// Check authentication status and navigate to appropriate page
  Future<void> _checkAuthAndNavigate() async {
    // Check if user is already authenticated
    final authProvider = context.read<AuthProvider>();
    await authProvider.checkAuthStatus();

    if (!mounted) return;

    // Let GoRouter's redirect logic handle navigation based on auth state
    // If signed in -> will redirect to /garage
    // If not signed in -> will redirect to /profile/signin
    context.go('/listings');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo at top
                Image.asset(
                  'assets/imgs/shine_logo.jpg',
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 60),

                if (_showError)
                  // Error state - show error message and retry button
                  Column(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 64,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Unable to connect to Aurae servers. Please check your internet connection and try again.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: _performHealthCheck,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  // Loading state - show spinner and message
                  Column(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 24),
                      Text(
                        'Welcome to Aurae',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isRetrying ? 'Connecting to server...' : 'Loading...',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
