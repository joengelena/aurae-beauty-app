import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:fetch_client/fetch_client.dart';

/// HTTP client factory - Web uses FetchClient for CORS, others use standard client
/// No native caching - caching is handled at application layer via remote_caching
class HttpClientFactory {
  static http.Client? _client;

  /// Get the platform-appropriate HTTP client (no caching)
  static http.Client getClient() {
    if (_client != null) return _client!;

    if (kIsWeb) {
      // Web: Use FetchClient for CORS support only (not for caching)
      _client = FetchClient(
        mode: RequestMode.cors,
        credentials: RequestCredentials.cors,
      );
    } else {
      // Mobile/Desktop: Use standard HTTP client (no caching)
      _client = http.Client();
    }

    return _client!;
  }

  /// Close and reset client (useful for testing)
  static void reset() {
    _client?.close();
    _client = null;
  }
}
