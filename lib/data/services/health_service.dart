import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shine_app/data/http_client.dart';
import 'package:shine_app/env_constants.dart';

/// Service for checking API health status
/// Does not use ApiClient to avoid auth/token refresh logic
class HealthService {
  final http.Client _client;

  HealthService() : _client = HttpClientFactory.getClient();

  /// Check API health with timeout
  /// Returns true if API returns 200 status with healthy response
  /// Throws TimeoutException if request takes longer than timeout
  /// Throws SocketException for network errors
  Future<bool> checkHealth({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    try {
      final uri = Uri.parse('$apiBaseUrl/health');

      final response = await _client
          .get(uri)
          .timeout(
            timeout,
            onTimeout: () {
              throw TimeoutException(
                'Health check timed out after ${timeout.inSeconds} seconds',
              );
            },
          );

      // Check status code
      if (response.statusCode != HttpStatus.ok) {
        return false;
      }

      // Validate response body
      try {
        final body = json.decode(response.body) as Map<String, dynamic>;
        final status = body['status'] as String?;
        final database = body['database'] as String?;

        // API is healthy if status is 'healthy' and database is 'connected'
        return status == 'healthy' && database == 'connected';
      } catch (e) {
        // Invalid JSON or missing fields
        return false;
      }
    } on TimeoutException {
      rethrow;
    } on SocketException {
      rethrow;
    } catch (e) {
      // Any other error means unhealthy
      return false;
    }
  }

  /// Check health with retry logic
  /// Retries up to maxRetries times with retryDelay between attempts
  /// Returns true if any attempt succeeds, false if all attempts fail
  Future<bool> checkHealthWithRetry({
    int maxRetries = 5,
    Duration retryDelay = const Duration(seconds: 2),
    Duration timeout = const Duration(seconds: 10),
  }) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final isHealthy = await checkHealth(timeout: timeout);
        if (isHealthy) {
          return true;
        }
      } catch (e) {
        // Continue to next retry
      }

      // Don't delay after the last failed attempt
      if (attempt < maxRetries) {
        await Future.delayed(retryDelay);
      }
    }

    return false;
  }
}
