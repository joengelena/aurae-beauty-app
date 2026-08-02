# Data Layer Rules — Services, ApiClient, Caching

## Hard Rules

1. **NEVER bypass `ApiClient`.** No widget, provider, or service may use `http.Client` directly. `ApiClient` owns auth headers, the 401 refresh-and-retry cycle, and cache invalidation — bypassing it silently loses all three.

2. **NEVER hardcode a cache key string.** Use `CacheKeys` in `utils/constants.dart`. Add a new entry there if one doesn't exist.

3. **NEVER hardcode the base URL.** It comes from `apiBaseUrl` in `env_constants.dart` (`--dart-define=API_BASE_URL`), and `ApiClient` prepends it. Service paths are relative: `'/user/dresses'`, not the full URL.

4. **NEVER touch `RequestCredentials.cors` in `http_client.dart`.** In the pinned `fetch_client` version this member serializes to `'include'` internally, so httpOnly cookies *are* sent cross-origin. There is no `.include` member. This has been "fixed" before and broke every authenticated web request.

5. **NEVER return a raw `http.Response` out of a service.** Services parse into models and throw `AppException` on failure.

6. **NEVER forget `invalidateCacheKeys` on a write.** A POST/PATCH/DELETE that doesn't invalidate leaves the UI showing stale data until the TTL expires.

## Service Shape

```dart
class DressServices {
  static final ApiClient apiClient = ApiClient();

  Future<List<BusinessDress>> getAllDresses() async {
    final response = await apiClient.get(
      '/user/dresses',
      cacheKey: CacheKeys.dresses,
      cacheDuration: CacheDurations.short,
    );

    if (response.statusCode != HttpStatus.ok) {
      throw AppException(extractErrorMessage(response.body), details: response.body);
    }
    // parse into models...
  }

  Future<Map<String, dynamic>> addDress(Map<String, dynamic> dressData) async {
    final response = await apiClient.post(
      '/user/dresses',
      dressData,
      invalidateCacheKeys: [CacheKeys.dresses, '*/dresses*'],
    );

    if (response.statusCode != HttpStatus.created) {
      throw AppException(extractErrorMessage(response.body), details: response.body);
    }
    // ...
  }
}
```

Use `HttpStatus` constants (`dart:io`) and `extractErrorMessage` from `utils/utils.dart` — don't compare raw integers or parse error bodies by hand.

## Caching

`ApiClient.get()` is **cached by default** and requires both `cacheKey` and `cacheDuration`. Backed by Hive (IndexedDB on web, native storage elsewhere).

Durations — pick from `CacheDurations`, don't invent one:

| Constant | Value | Use for |
|---|---|---|
| `short` | 5 min | User-specific data that changes often (wardrobe, cart, bookings) |
| `medium` | 10 min | Public data (browse feed, dress detail) |
| `long` | 1 hour | Static config (attributes, dropdown options) |

**Stale data is a cache problem, not an endpoint problem.** Reach for `bypassCache: true` or a correct `invalidateCacheKeys` list before adding a new route.

Invalidation supports two forms:

- Exact key — `CacheKeys.dresses`
- Wildcard pattern — `'*/dresses*'` clears every key containing `/dresses`

Writes that affect both the owner's Wardrobe and the public Browse feed need **both**: `[CacheKeys.dresses, '*/dresses*']`.

## Auth Handling — Web vs Mobile

`ApiClient._buildHeaders()` sets `x-client-type` to `web` or `flutter`:

- **Web** — relies on httpOnly cookies set by the API. No `Authorization` header unless `forceAuthHeader: true`.
- **Mobile/desktop** — reads `accessToken` from `SecureStorage` and sets `Authorization: Bearer …`.

Any change to auth must work on both paths. Verify web *and* mobile before considering an auth change done.

On a 401, `ApiClient` refreshes the token once and retries. Concurrent refreshes are coordinated through a single `Completer`. `/signin`, `/signup`, and `/refresh-token` skip retry to avoid infinite loops — if you add another auth endpoint, add it to `_authEndpoints`.

## Exceptions

Defined in `data/exceptions/app_exception.dart`:

- `AppException` — base, carries `message` + optional `details`
- `AuthException` — auth failures
- `NetworkException` — adds `statusCode`

Throw the most specific one. `message` is shown to the user, so write it in plain language — `details` carries the raw body for debugging.

## Image Upload

Use `apiClient.postMultipart` / `patchMultipart`. They buffer file bytes up front so a 401 retry can rebuild fresh streams — a plain `MultipartRequest` cannot be replayed and will fail silently on retry.
