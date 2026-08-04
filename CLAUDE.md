# shine_app — Flutter Client

Flutter app for AURAE, a dress rental marketplace. Runs on iOS, Android, and Web from one codebase. Serves two audiences: **renters** (Browse, cart, bookings) and **boutique owners** (Wardrobe, inventory, booking management).

Monorepo context and the `user_dresses` data model rule: `../CLAUDE.md`.

**Conventions live in `.claude/rules/`:**

| Rule | Covers |
|---|---|
| `feature-workflow.md` | **Start here when adding a feature** — ordered checklist, model → service → provider → route → page |
| `state-management.md` | Provider patterns, the standard `ChangeNotifier` shape, Consumer vs Selector |
| `data-layer.md` | Services, `ApiClient`, caching, the web/mobile auth split |
| `models.md` | `fromJson` conventions, the current model inventory |
| `routing-and-auth.md` | `go_router` config, `_publicPages`, auth flow, the port-8080 rule |
| `ui-and-theming.md` | Palette, typography, spacing, reusable widget inventory |
| `ui-states.md` | Loading / error / empty / success handling |
| `widgets.md` | `const`, `mounted` checks, disposing controllers, rebuild discipline |
| `code-style.md` | Imports, naming, no magic numbers, logging, formatting |

---

## Stack

Flutter · Provider (`ChangeNotifier`) · `go_router` 16 · Hive (cache) · Supabase Auth · `http` + `fetch_client` · `flutter_secure_storage` · `table_calendar` · `cached_network_image`

**Do not introduce Riverpod, Bloc, or Redux.** Provider is the state management for this project.

---

## Architecture — 3 Layers

```
presentation/  pages + widgets (UI only)
logic/         ChangeNotifier providers (state + orchestration)
data/          services → api_client → http_client (network, models, cache)
```

Data flows one way: **Page → Provider → Service → ApiClient → API.** A page never calls a service directly; a service never touches a provider.

```
lib/
├── main.dart            MultiProvider tree + Hive/Supabase init
├── app_router.dart      go_router config, redirect/auth guard, shell route
├── env_constants.dart   String.fromEnvironment config (API_BASE_URL, Supabase keys)
├── data/
│   ├── api_client.dart      HTTP verbs, auth headers, 401 refresh+retry, cache invalidation
│   ├── http_client.dart     Platform client factory (FetchClient on web)
│   ├── cache_manager.dart   Hive-backed TTL cache
│   ├── models/              12 models, each with fromJson
│   ├── services/            One class per domain (DressServices, UserServices, ...)
│   └── exceptions/          AppException, AuthException, NetworkException
├── logic/               15 providers
├── presentation/
│   ├── pages/           16 top-level pages + pages/profile/
│   └── widgets/         common/ form_fields/ listing/ profile/ scaffold/ wardrobe/
└── utils/               theme, constants, secure_storage, helpers
```

---

## Providers (`lib/logic/`)

Registered in `main.dart`. Most are `ChangeNotifierProxyProvider<AuthProvider, X>` and receive `updateAuthStatus(isSignedIn)` — they reset their own state on sign-out.

| Provider | Responsibility |
|---|---|
| `AuthProvider` | Sign in/up/out, token state, `isAuthInitialized`. Drives router redirects. |
| `ProfileProvider` | Current user profile. Also drives router redirects. |
| `WardrobeProvider` | Owner's dresses; splits `activeDresses` / `soldDresses` by `status`. |
| `DressDetailProvider` | Single owner dress + its bookings + damage incidents. |
| `ListingsProvider` | Public Browse feed, pagination, user location. |
| `ListingDetailProvider` | Public dress detail page + size variants. |
| `FilteringProvider` | Browse filter state + attribute dropdown options. |
| `CartProvider` | Cart items and `checkout()`. |
| `WatchlistProvider` | Saved dresses. |
| `WeekScheduleProvider` | Wardrobe-wide Day/Week/Month schedule. |
| `UpcomingBookingsProvider` | Upcoming bookings summary. |
| `BusinessSettingsProvider` | `business_settings` (delivery option, cleaning buffer). |
| `OwnerProfileProvider` | Public boutique profile. |
| `BackButtonProvider` | Navigation back-state. |
| `FormDataProvider` | Shared form scratch state. |

There is no `BookingProvider` — booking state lives in `DressDetailProvider` and `WeekScheduleProvider`.

---

## Models (`lib/data/models/`)

`business_dress.dart` (**`BusinessDress`** — the main dress model, mirrors `user_dresses`), `rental_booking.dart`, `dress_damage_incident.dart`, `cart_item.dart`, `business_settings.dart`, `upcoming_booking.dart`, `booked_range.dart`, `dress_listing.dart`, `listing.dart`, `listing_attribute.dart`, `pagination.dart`, `user.dart`.

`BusinessDress` fields include `status` (`active`/`sold`), `isPublic`, `blockedDateRanges` (`List<DateTimeRange>`), `unresolvedDamageCount`, `pendingBookingCount`, `dressPhotoUrls`, `rentalPricePerDay`.

`listing.dart` / `dress_listing.dart` are the **public Browse-side** representations and are still live — don't delete them as "legacy". Only the old `/listings` *API* was retired.

---

## Services (`lib/data/services/`)

`DressServices` (largest — dresses, bookings, damage incidents, attributes), `UserServices`, `CartServices`, `WatchlistServices`, `HealthService`.

Every service holds `static final ApiClient apiClient = ApiClient();`, throws `AppException` on non-2xx, and passes `invalidateCacheKeys` on writes. Cache keys come from `CacheKeys` in `utils/constants.dart` — never hand-write a key string.

---

## Dev Workflow

**Run web via the VS Code Run button. Never `flutter run` in the terminal.** Port 8080 is whitelisted in the API's `ALLOWED_COOKIE_ORIGINS`; any other port breaks every request with CORS errors.

```bash
flutter analyze          # must be clean before committing
flutter test             # test/data/, test/presentation/
flutter pub get
```

Config is compile-time via `--dart-define` (`API_BASE_URL`, `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `APP_BASE_URL`, `ENVIRONMENT`). Defaults in `env_constants.dart` point at `http://localhost:4941/api/v1`.

---

## Landmines

**`RequestCredentials.cors` in `http_client.dart` is correct — do not "fix" it.** In the pinned `fetch_client` version this enum member serializes to `'include'` under the hood, so the browser does send httpOnly cookies cross-origin. There is no `.include` member. This has been mistakenly "corrected" before and broke all authenticated web requests.

**Web vs mobile auth differ.** `ApiClient` sends `x-client-type: web` or `flutter`. Web relies on httpOnly cookies; mobile reads tokens from `SecureStorage` and sets an `Authorization` header. Code touching auth must handle both.

**`ApiClient.get()` is cached by default.** It requires `cacheKey` and `cacheDuration`. If you're not seeing fresh data, you want `bypassCache: true` — not a new endpoint.

**401s auto-refresh and retry once**, coordinated through a `Completer` so concurrent requests don't stampede. `/signin`, `/signup`, `/refresh-token` skip retry to avoid infinite loops.

---

## Known Issues

- `BookingCalendar` (per-dress month view) doesn't visually paint the cleaning buffer or manually blocked dates. The validation is enforced server-side; only the Add Booking date picker renders it.
- `dress_listing.dart` still falls back to a `vehicleCondition` JSON key. Cosmetic Motorix leftover — safe to remove once you've confirmed no endpoint still returns it.
- Test coverage is thin — two test files (`health_service_test.dart`, `splash_page_test.dart`).
