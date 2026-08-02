# Routing & Auth Rules

Routing is `go_router` 16, configured in `lib/app_router.dart` via `getAppRouter(authProvider, profileProvider)`.

## Hard Rules

1. **NEVER use `Navigator.push` for a top-level screen.** Use `context.go()` / `context.push()` so the URL stays correct on web. Raw `Navigator` is acceptable only for modals and bottom sheets.

2. **NEVER hardcode a route string in a widget** without it existing in `app_router.dart`. Web users can deep-link to any path — an unregistered path hits `errorBuilder` and bounces to `/listings`.

3. **NEVER add an auth check inside a page.** Auth gating belongs in the router's `redirect`. Pages assume they're allowed to render.

4. **NEVER add a screen to the shell route without checking the bottom nav.** Shell routes render inside `AppScaffold` with `AppNavigation`; full-screen pages use the root navigator.

## Router Structure

- `initialLocation: '/splash'` — splash runs the health + auth check before anything else
- `refreshListenable: Listenable.merge([authProvider, profileProvider])` — the router re-evaluates redirects whenever either changes
- `_rootNavigatorKey` — full-screen pages (no bottom nav)
- `_shellNavigatorKey` — pages inside `AppScaffold`
- `errorBuilder` — redirects to `/listings`

Two route lists drive the redirect logic:

```dart
const _authPages = [                    // signed-in users are bounced OUT of these
  '/profile/signin', '/profile/signup', '/profile/forgot-password',
  '/profile/reset-password', '/profile/email-verification',
];

const _publicPages = ['/listings', '/watchlist', '/wardrobe', '/privacy'];
```

**Adding a route that unauthenticated users should reach means adding it to `_publicPages`.** Forgetting this is the usual cause of "it redirects me to sign-in for no reason."

## Auth Flow

Supabase Auth is the credential source of truth. `AuthProvider` owns the client-side state.

**Startup:** `main.dart` calls `_checkAuthSilently` — if tokens exist in `SecureStorage`, it validates in the background so a page refresh doesn't bounce the user through splash. If no tokens, the router sends them to `/splash` for the full health + auth check.

**Key `AuthProvider` state:**

- `isSignedIn` — gates redirects
- `isAuthInitialized` — **check this before redirecting.** Redirecting while auth is still resolving flashes the sign-in page at authenticated users.
- `isLoading`

**Token storage:**

- Web — httpOnly cookies set by the API. Never readable from Dart, and that's intentional.
- Mobile/desktop — `SecureStorage` (`userId`, `accessToken`, `refreshToken`).

**Sign-out must clear the cache.** Call `ApiClient.clearCache()`; providers reset themselves through `updateAuthStatus`. Skipping this leaks the previous user's data into the next session.

## Email Verification Redirects

Supabase redirects back to `emailVerificationRedirectUrl` in `env_constants.dart` — `$appBaseUrl/#/profile/email-verification`. This depends on `APP_BASE_URL` (default `http://localhost:8080`), which is another reason web must run on port 8080. The router also intercepts Supabase error fragments and routes them to the verification page.

## Web Port — Non-Negotiable

Run Flutter web through the **VS Code Run button**, never `flutter run` in a terminal. Port 8080 is whitelisted in the API's `ALLOWED_COOKIE_ORIGINS`. On any other port, cookies aren't set, every authenticated request fails CORS, and the app looks broken in ways that have nothing to do with the code you just wrote.
