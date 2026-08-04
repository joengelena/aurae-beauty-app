# Adding a Feature — Checklist

Follow these in order. **Data layer first, UI last.** Skipping ahead to the page and back-filling the service is how duplicate models and orphaned cache keys get created.

## 1. Confirm the API Contract

Check `../../shine_api/docs/api-endpoints.md` for the path, method, params, and response shape. If the endpoint doesn't exist yet, build it in `shine_api` first — **never infer the response shape from memory** and never invent a field the API doesn't return.

## 2. Model — `lib/data/models/`

`snake_case.dart`, all fields `final`, a `fromJson` factory, `copyWith` only if something mutates it. Nullable-with-default for every optional field. See `models.md`.

Check the existing 12 models first — extend one rather than adding a near-duplicate.

## 3. Cache Key — `lib/utils/constants.dart`

Add the entry to `CacheKeys` before writing the service, so the service never hand-writes a key string. Pick a TTL from `CacheDurations`.

## 4. Service — `lib/data/services/`

Add the method to the existing domain service (`DressServices`, `UserServices`, `CartServices`, `WatchlistServices`) — only create a new service for a genuinely new domain.

- Go through `ApiClient`, never `http.Client`
- Throw `AppException` with a human-readable message on non-2xx
- Reads pass `cacheKey` + `cacheDuration`; writes pass `invalidateCacheKeys`

See `data-layer.md`.

## 5. Provider — `lib/logic/`

Extend `ChangeNotifier`. Standard `_isLoading` / `_errorMessage` shape, `List.unmodifiable` getters, `updateAuthStatus` + `reset()` if the data is user-scoped.

Loads swallow the error into `_errorMessage`; mutations `rethrow`. See `state-management.md`.

Never touch `BuildContext` or navigation from a provider.

## 6. Register It — `lib/main.dart`

Add to the `MultiProvider` list. User-scoped data uses `ChangeNotifierProxyProvider<AuthProvider, X>` so it resets on sign-out:

```dart
ChangeNotifierProxyProvider<AuthProvider, MyProvider>(
  create: (_) => MyProvider(),
  update: (context, authProvider, myProvider) {
    myProvider!.updateAuthStatus(authProvider.isSignedIn);
    return myProvider;
  },
),
```

## 7. Route — `lib/app_router.dart`

Add the `GoRoute`. Two things people forget:

- **Shell vs root navigator** — inside `AppScaffold` (bottom nav visible) or full-screen?
- **`_publicPages`** — if unauthenticated users should reach it, add the path. Missing this is the usual cause of "it redirects me to sign-in for no reason."

See `routing-and-auth.md`.

## 8. Page — `lib/presentation/pages/`

Handle loading, error, empty, and success — all four. Read state via `Consumer`/`Selector`, trigger the fetch from `initState` with a post-frame callback. Never call a service directly from a page.

See `ui-states.md`.

## 9. Extract Reusable UI

Pull repeated pieces into the right `presentation/widgets/` subfolder. Check `common/` and `form_fields/` before building anything new — see `ui-and-theming.md` for the inventory.

## 10. Verify

```bash
flutter analyze     # must be clean
flutter test
```

Then exercise it **in the browser via the VS Code Run button** (port 8080 — see `routing-and-auth.md`) and on a mobile target if the change touches auth, since web and mobile use different token paths.

## Before You Call It Done

- [ ] `flutter analyze` clean
- [ ] All four UI states handled
- [ ] No hardcoded colors, spacing, or cache-key strings
- [ ] Writes invalidate the right cache keys — including `'*/dresses*'` if Browse is affected
- [ ] Controllers disposed, `mounted` checked after every `await` that precedes a `context` use
- [ ] `const` used wherever the linter allows
- [ ] New public route added to `_publicPages` if it should be reachable signed-out

## Fixing a Bug

The codebase has thin test coverage, so the bar is: **reproduce it, fix it, and leave a note or a test.**

1. Reproduce it first — confirm you're looking at the real cause, not a symptom.
2. Make the smallest change that fixes it.
3. If the bug was in a model, service, or provider, a unit test is cheap — add one.
4. If it was a caching or auth-path bug, verify on **both** web and mobile before closing it out.
