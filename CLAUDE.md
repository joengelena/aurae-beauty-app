# CLAUDE.md - Motorix App Reference Guide

This document serves as a persistent reference for all development tasks in this codebase. It captures the actual patterns, conventions, and architecture used in the project.

---

## 1. Project Overview

**App Name:** Motorex
**Purpose:** A car marketplace application for buying and selling cars, own vehicle maintenance service
**Target Platforms:** iOS, Android, Web

### Core Features

- **Listings Marketplace:** Browse, search, filter, and view car listings
- **Watchlist:** Save favorite listings for later viewing
- **Garage Management:** Track personal vehicles with service history and compliance dates (registration, WOF)
- **Post Listings:** Create and manage car sale listings with images
- **User Authentication:** Sign up, sign in, email verification, password management
- **Profile Management:** Edit profile, change password, delete account
- **Notifications:** Vehicle compliance reminders (registration/WOF expiry/insurance expiry)

---

## 2. Architecture Pattern

### State Management: Provider (NOT Riverpod/Bloc/GetX)

- Uses the **Provider** package (v6.1.5) with `ChangeNotifier`
- Providers are registered in `main.dart` using `MultiProvider`
- Uses `ChangeNotifierProvider` and `ChangeNotifierProxyProvider` for dependency injection
- All providers extend `ChangeNotifier` and call `notifyListeners()` to update UI

### Folder Structure (3-Layer Architecture)

```
lib/
├── data/                    # Data layer
│   ├── models/             # Data models (manual fromJson/toJson)
│   ├── services/           # API service classes
│   ├── exceptions/         # Custom exception classes
│   ├── api_client.dart     # Centralized HTTP client
│   ├── http_client.dart    # HTTP client factory
│   └── cache_manager.dart  # Hive-based caching
│
├── logic/                   # Business logic layer (Providers)
│   ├── auth_provider.dart
│   ├── listings_provider.dart
│   ├── garage_provider.dart
│   └── ... (other providers)
│
├── presentation/           # Presentation layer
│   ├── pages/             # Full-screen pages
│   │   ├── listings_page.dart
│   │   ├── garage_page.dart
│   │   └── profile/       # Profile-related pages
│   │       ├── sign_in_page.dart
│   │       ├── sign_up_page.dart
│   │       └── ...
│   │
│   └── widgets/           # Reusable widget components
│       ├── common/        # Shared widgets across features
│       ├── listing/       # Listing-specific widgets
│       ├── garage/        # Garage-specific widgets
│       ├── form_fields/   # Custom form field widgets
│       └── scaffold/      # App scaffold components
│
├── utils/                  # Utilities and helpers
│   ├── theme.dart         # App theme configuration
│   ├── constants.dart     # App-wide constants
│   ├── secure_storage.dart # Secure storage wrapper
│   ├── feedback_helpers.dart # Dialog/snackbar helpers
│   └── utils.dart         # General utility functions
│
├── app_router.dart        # GoRouter configuration
├── env_constants.dart     # Environment variables
└── main.dart              # App entry point
```

### Naming Conventions

#### Files

- `snake_case.dart` for all files
- Page files: `{feature}_page.dart` (e.g., `listings_page.dart`, `garage_page.dart`)
- Provider files: `{feature}_provider.dart` (e.g., `auth_provider.dart`)
- Service files: `{feature}_services.dart` (e.g., `user_services.dart`, `listings_services.dart`)
- Model files: `{model_name}.dart` (e.g., `user.dart`, `listing.dart`)
- Widget files: Descriptive names (e.g., `filter_bar.dart`, `vehicle_card.dart`)

#### Classes

- `PascalCase` for all classes
- Pages: `{Feature}Page` (e.g., `ListingsPage`, `GaragePage`)
- Providers: `{Feature}Provider` (e.g., `AuthProvider`, `ListingsProvider`)
- Services: `{Feature}Services` (e.g., `UserServices`, `ListingsServices`)
- Models: Plain nouns (e.g., `User`, `Listing`, `VehicleService`)
- Widgets: Descriptive names (e.g., `FilterBar`, `VehicleCard`, `InfiniteGrid`)

#### Variables

- `camelCase` for variables and function names
- Private variables: `_camelCase` with underscore prefix
- Boolean variables: Use `is`, `has`, `can` prefixes (e.g., `isLoading`, `hasError`, `canLoadMore`)

---

## 3. Tech Stack & Key Dependencies

### Core Framework

- **Flutter SDK:** ^3.7.2
- **Dart SDK:** ^3.7.2

### State Management

- **provider:** 6.1.5 - State management with ChangeNotifier

### Routing

- **go_router:** 16.0.0 - Declarative routing with deep linking support

### Backend & Storage

- **supabase_flutter:** ^2.8.0 - Backend-as-a-Service (authentication, database)
- **hive:** ^2.2.3 - Local NoSQL database for caching
- **hive_flutter:** ^1.1.0 - Hive initialization for Flutter
- **flutter_secure_storage:** 9.2.4 - Secure storage for tokens and sensitive data

### HTTP & Networking

- **http:** 1.4.0 - HTTP client for API calls
- **fetch_client:** 1.1.2 - HTTP client wrapper (cookie support for web)
- **http_parser:** 4.1.2 - MIME type parsing for multipart requests

### UI & UX

- **smooth_page_indicator:** 1.2.1 - Page indicators for image carousels
- **image_picker:** 1.1.2 - Pick images from gallery/camera

### Utilities

- **intl:** 0.20.2 - Internationalization and date formatting
- **permission_handler:** ^11.0.0 - Permission requests (notifications)
- **timezone:** 0.9.4 - Timezone support for notifications
- **flutter_local_notifications:** 18.0.1 - Local push notifications

### Dev Tools

- **flutter_lints:** 5.0.0 - Linting rules
- **flutter_launcher_icons:** ^0.14.1 - App icon generation

### Code Generation

**NONE** - This project does NOT use:

- ❌ `freezed`
- ❌ `json_serializable`
- ❌ `build_runner`

All models use **manual `fromJson` and `toJson` methods**.

---

## 4. Code Patterns & Conventions

### Model Structure

Models are plain Dart classes with:

- Immutable fields (`final`)
- Named constructor parameters
- Manual `fromJson` factory constructors
- Manual `copyWith` methods (when needed)
- Optional `toString()` override

```dart
class User {
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String location;
  final String? profilePhotoUrl;

  User({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.location,
    this.profilePhotoUrl,
  });

  factory User.fromJsonString(String jsonString) {
    Map<String, dynamic> decodedJson = json.decode(jsonString);
    return User(
      firstName: decodedJson['firstName'] as String,
      lastName: decodedJson['lastName'] as String,
      email: decodedJson['email'] as String,
      phoneNumber: decodedJson['phoneNumber'] as String,
      location: decodedJson['location'] as String,
      profilePhotoUrl: decodedJson['profilePhotoUrl'] as String?,
    );
  }
}
```

**Key Points:**

- Use `fromJson(json)` or `fromJsonString(String jsonString)` factory constructors
- Some models have both `fromJson` and `fromJsonString`
- Use explicit type casting (`as String`, `as int`, `as String?`)
- Handle nullable fields with `?` and null-aware operators
- Add `copyWith` for models that need immutable updates (e.g., `Listing`)

### Service Layer (API Calls)

Services handle all API communication:

- Use `ApiClient` for all HTTP requests
- Throw custom exceptions (`AppException` subclasses)
- Return typed data models or `Map<String, dynamic>`
- Services are stateless classes with static or instance methods

```dart
class UserServices {
  static final ApiClient apiClient = ApiClient();

  Future<User> getUserWithId(String userId) async {
    try {
      http.Response response = await apiClient.get(
        '/users/$userId',
        cacheKey: CacheKeys.userDetails(userId),
        cacheDuration: CacheDurations.short,
      );

      if (response.statusCode == HttpStatus.notFound) {
        throw NotFoundException('User not found with ID: $userId');
      }

      if (response.statusCode != HttpStatus.ok) {
        throw NetworkException(
          'Failed to get user',
          statusCode: response.statusCode,
          details: response.body,
        );
      }

      return User.fromJsonString(response.body);
    } catch (e) {
      if (e is NotFoundException || e is NetworkException) rethrow;
      throw NetworkException('Network error getting user', details: e.toString());
    }
  }
}
```

**Key Points:**

- Always use try-catch blocks
- Check HTTP status codes explicitly
- Throw specific exception types (see Exceptions section)
- Use `extractErrorMessage(response.body)` utility to parse API error messages
- Rethrow known exceptions, wrap unknown ones in `NetworkException`
- Use cache keys from `CacheKeys` class (in `utils/constants.dart`)

### ApiClient Pattern

The `ApiClient` class centralizes all HTTP requests with:

- Automatic token refresh on 401 responses
- Cache management with Hive
- Multipart request support
- Cache invalidation after mutations

```dart
// GET request with caching
final response = await apiClient.get(
  '/listings',
  cacheKey: CacheKeys.listings(queryParams),
  cacheDuration: CacheDurations.medium,
  queryParameters: queryParams,
);

// POST request with cache invalidation
final response = await apiClient.post(
  '/listings',
  data,
  invalidateCacheKeys: [CacheKeys.allListingsCache],
);

// Multipart request (with images)
final response = await apiClient.postMultipart(
  '/listings',
  fields,
  files,
  invalidateCacheKeys: [CacheKeys.allListingsCache],
);
```

**Cache Invalidation Patterns:**

- Use specific keys: `CacheKeys.listing(123)`
- Use wildcard patterns: `CacheKeys.allListingsCache` (defined as `'*listings*'`)
- Provide `invalidateCacheKeys` parameter for POST/PATCH/DELETE requests

### Provider Pattern

Providers manage application state and business logic:

- Extend `ChangeNotifier`
- Contain state properties (e.g., `isLoading`, `errorMessage`)
- Call services for data operations
- Call `notifyListeners()` after state changes
- Handle loading/error states in the provider

```dart
class AuthProvider extends ChangeNotifier {
  final UserServices _userServices = UserServices();

  bool isLoading = false;
  bool isSignedIn = false;
  String signInErrorMessage = '';

  Future<void> signIn(String email, String password) async {
    isLoading = true;
    signInErrorMessage = '';
    notifyListeners();

    try {
      await _userServices.signIn(email, password);
      isSignedIn = true;
    } catch (e) {
      if (e is AppException) {
        signInErrorMessage = e.message;
      } else {
        signInErrorMessage = 'Unexpected error occurred';
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
```

**Key Points:**

- Always set `isLoading = true` before async operations
- Clear error messages before new operations
- Use `finally` to ensure `isLoading` is reset
- Check if exception is `AppException` before accessing `.message`
- Provide clear state methods (e.g., `clearSignInState()`)

### Provider Access in UI

Follow these patterns for accessing providers:

```dart
// Read provider value (in build method)
final authProvider = context.watch<AuthProvider>();

// Read provider once (not reactive)
final authProvider = context.read<AuthProvider>();

// Call provider methods (in callbacks/event handlers)
onPressed: () {
  context.read<AuthProvider>().signIn(email, password);
}

// Listen to specific values using Selector (optimization)
Selector<AuthProvider, bool>(
  selector: (_, provider) => provider.isLoading,
  builder: (_, isLoading, __) => isLoading ? CircularProgressIndicator() : SomeWidget(),
)
```

**Rules:**

- Use `context.watch<T>()` in `build()` to rebuild on changes
- Use `context.read<T>()` in callbacks/event handlers (no rebuild)
- Never use `context.read<T>()` directly in `build()` if you need reactivity
- Use `Selector` to optimize rebuilds for specific properties

### Routing (GoRouter)

Routes are defined in `app_router.dart`:

- Uses `ShellRoute` for persistent bottom navigation
- Uses `NoTransitionPage` for instant navigation (no animation)
- Path parameters: `:paramName` (e.g., `/listings/:listingId`)
- Auth-based redirects handled in `redirect` callback

```dart
// Always navigate with the go() method
context.go('/listings/123');       // Replace current route

// Access path parameters
final listingId = state.pathParameters['listingId'];

// Access query parameters
final errorCode = Uri.splitQueryString(state.uri.path)['error_code'];
```

**Route Naming:**

- Use lowercase with hyphens: `/profile/sign-in`, `/forgot-password`
- Nested routes: `/garage/:vehicleId/add-service`
- Use `parentNavigatorKey: _shellNavigatorKey` for routes inside ShellRoute

### Error Handling & Loading States

#### Exceptions Hierarchy

```
AppException (base)
├── AuthException
├── NetworkException
├── DataParseException
├── NotFoundException
├── UnauthenticatedException
└── ForbiddenException
```

#### Error Handling Pattern

```dart
try {
  // API call or operation
} catch (e) {
  if (e is AppException) {
    // Handle known exception with e.message
  } else {
    // Handle unexpected error
  }
}
```

#### Loading State Pattern

```dart
// In provider
bool isLoading = false;

Future<void> fetchData() async {
  isLoading = true;
  notifyListeners();

  try {
    // Fetch data
  } finally {
    isLoading = false;
    notifyListeners();
  }
}

// In UI
if (provider.isLoading) {
  return CircularProgressIndicator();
}
```

#### User Feedback

```dart
// Success feedback
FeedbackHelpers.showSuccessSnackBar(context, 'Operation successful');

// Error feedback
FeedbackHelpers.showErrorSnackBar(context, 'Operation failed');

// Delete confirmation
final confirmed = await FeedbackHelpers.showDeleteConfirmation(
  context,
  title: 'Delete Item',
  message: 'Are you sure?',
);
```

### Widget Decomposition Rules

**When to extract a widget:**

1. **Reusability:** Widget is used in multiple places
2. **Complexity:** Widget has >50 lines of code or complex logic
3. **Separation of Concerns:** Widget handles a distinct UI feature
4. **Performance:** Widget rebuild optimization needed

**Widget Organization:**

- **Common widgets:** `presentation/widgets/common/` (used across features)
- **Feature widgets:** `presentation/widgets/{feature}/` (feature-specific)
- **Form fields:** `presentation/widgets/form_fields/` (reusable form inputs)

**Examples:**

- `FilterBar` - Complex filter UI (50+ lines)
- `VehicleCard` - Reusable garage vehicle display
- `AppDialog` - Common dialog component
- `LabeledFab` - Reusable floating action button with label

---

## 5. Common Commands

### Run the App

```bash
# Development (debug mode)
flutter run

# Web
flutter run -d chrome

# Specific device
flutter run -d <device-id>

# Release mode
flutter run --release
```

### Build the App

```bash
# Android APK
flutter build apk

# Android App Bundle (for Play Store)
flutter build appbundle

# iOS
flutter build ios

# Web
flutter build web

# macOS
flutter build macos
```

### Testing

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart
```

### Dependencies

```bash
# Get dependencies
flutter pub get

# Upgrade dependencies
flutter pub upgrade

# Outdated packages
flutter pub outdated
```

### Code Generation

**NOT APPLICABLE** - This project does not use code generation tools.

### Icons

```bash
# Generate app icons
flutter pub run flutter_launcher_icons
```

### Clean Build

```bash
flutter clean
flutter pub get
```

---

## 6. Do's and Don'ts

### Provider Usage

#### DO:

- Always use `context.watch<Provider>()` in `build()` when you need reactive updates
- Use `context.read<Provider>()` in callbacks and event handlers
- Set `isLoading = true` before async operations
- Clear error messages before new operations
- Use `finally` to reset loading states
- Call `notifyListeners()` after state changes

#### DON'T:

- Never use `context.watch<Provider>()` in callbacks (causes rebuilds on every call)
- Don't forget to call `notifyListeners()` after state changes
- Don't access provider properties without null checks in UI
- Don't use Provider for ephemeral/local widget state (use StatefulWidget)

### Model & Data Handling

#### DO:

- Use explicit type casting in `fromJson`: `json['field'] as String`
- Handle nullable fields with `?` and null-aware operators
- Add `copyWith` methods for models that need immutable updates
- Use `final` for all model fields
- Validate data before parsing (check status codes, null values)

#### DON'T:

- Don't use code generation tools (freezed, json_serializable)
- Don't create mutable models
- Don't parse JSON without type casting
- Don't assume API responses are always valid

### API & Services

#### DO:

- Always use `ApiClient` for HTTP requests
- Provide cache keys and durations for GET requests
- Invalidate cache after mutations (POST/PATCH/DELETE)
- Use specific exception types (AuthException, NetworkException, etc.)
- Check HTTP status codes explicitly
- Rethrow known exceptions, wrap unknown ones

#### DON'T:

- Don't make direct HTTP calls without ApiClient
- Don't ignore cache invalidation after mutations
- Don't swallow exceptions silently
- Don't forget to handle 401 (unauthorized) responses

### Routing & Navigation

#### DO:

- Use `context.go()` for replacing current route
- Use path parameters for resource IDs (`:listingId`)
- Use query parameters for optional filters/flags
- Handle route errors gracefully with `errorBuilder`

#### DON'T:

- Don't use `Navigator.push()` (use GoRouter methods instead)
- Dont't use `context.push()` for navigating
- Don't hard-code route strings (except in `app_router.dart`)
- Don't navigate without checking `context.mounted` in async callbacks

### UI & Widgets

#### DO:

- Extract complex widgets (>50 lines) into separate files
- Use `const` constructors whenever possible
- Dismiss keyboard when tapping outside text fields (GestureDetector in AppScaffold)
- Use theme colors from `utils/theme.dart` (themeBlue, themeGreen, themeRed, themeOrange)
- Use `FeedbackHelpers` for consistent snackbars and dialogs
- Check `context.mounted` before showing dialogs/snackbars after async operations

#### DON'T:

- Don't hard-code colors (use theme)
- Don't create giant widget trees (decompose into smaller widgets)
- Don't use `setState` in pages (use Provider instead)
- Don't forget to dispose controllers (TextEditingController, etc.)

### Performance & Optimization

#### DO:

- Use Hive caching for API responses
- Use `Selector` widget to optimize rebuilds
- Dispose resources in provider `dispose()` method
- Use pagination for large lists (see `ListingsProvider.getMoreListings`)
- Implement infinite scroll for better UX

#### DON'T:

- Don't fetch all data at once (use pagination)
- Don't rebuild entire widget trees unnecessarily
- Don't ignore memory leaks (controllers, streams, listeners)

### Error Messages & User Feedback

#### DO:

- Show user-friendly error messages
- Use `extractErrorMessage()` to parse API errors
- Display loading indicators during async operations
- Use themed snackbars (green for success, red for error, blue for info)
- Confirm destructive actions (delete, sign out)

#### DON'T:

- Don't show raw exception messages to users
- Don't leave users without feedback after actions
- Don't block UI without loading indicators

### Security & Authentication

#### DO:

- Store tokens in `flutter_secure_storage`
- Clear cache on sign out
- Refresh tokens automatically on 401 responses
- Validate user input before API calls
- Use Supabase auth for email verification

#### DON'T:

- Don't store sensitive data in shared preferences or Hive
- Don't expose API keys in code (use `env_constants.dart`)
- Don't skip email verification

---

## Project-Specific Patterns

### BackButtonProvider

- Used to maintain navigation history for custom back button behavior
- Push current route before navigating: `context.read<BackButtonProvider>().pushRoute(currentRoute)`

### ListingFormDataProvider

- Special provider pattern: `Provider<ListingFormDataProvider>` points to `PostListingProvider`
- Allows different interfaces for same provider (form data access vs full provider)

### Authentication Flow

1. User signs up → email verification required
2. User signs in → tokens stored in secure storage
3. ApiClient auto-refreshes tokens on 401
4. On sign out → clear cache, clear tokens

### Cache Strategy

- **Short (5 min):** User-specific frequently changing data
- **Medium (10 min):** Public data that changes regularly (listings)
- **Long (1 hour):** Static/configuration data
- Use wildcard invalidation: `'*listings*'` to clear all listing caches

### Notification Pattern

- Uses `VehicleNotificationService` for local notifications
- Schedules reminders for vehicle compliance (registration/WOF expiry)
- Notification tap handler navigates to specific vehicle: `/garage/$vehicleId`

### Image Handling

- Use `image_picker` for selecting images
- Send images as multipart requests via `ApiClient.postMultipart()`
- Images are stored in Supabase Storage

### Form Patterns

- Custom form fields in `presentation/widgets/form_fields/`
- Use `TextEditingController` for form inputs
- Dispose controllers in provider or widget `dispose()` method

---

## Environment & Configuration

### Environment Variables

Stored in `lib/env_constants.dart`:

- `apiBaseUrl` - Backend API base URL
- `supabaseUrl` - Supabase project URL
- `supabaseAnonKey` - Supabase anonymous key
- `emailVerificationRedirectUrl` - Email verification redirect URL

### Theme Configuration

Defined in `lib/utils/theme.dart`:

- Primary: Black
- Secondary: `themeBlue` (#1E3A8A)
- Success: `themeGreen` (#15803D)
- Error: `themeRed` (#B91C1C)
- Warning: `themeOrange` (#EA580C)
- Font: Poppins (Regular, Medium, SemiBold, Bold)

### Constants

Defined in `lib/utils/constants.dart`:

- `AppConstants`: UI constants (spacing, breakpoints, aspect ratios)
- `CacheDurations`: Cache duration presets
- `CacheKeys`: Cache key builders for consistent caching

---

## Summary Checklist for New Tasks

When implementing new features:

- [ ] Use Provider for state management (ChangeNotifier)
- [ ] Create service classes for API calls using ApiClient
- [ ] Define models with manual fromJson/toJson
- [ ] Handle errors with custom exception types
- [ ] Implement loading states (isLoading)
- [ ] Use cache keys and invalidation for API calls
- [ ] Extract complex widgets (>50 lines)
- [ ] Use context.watch in build, context.read in callbacks
- [ ] Follow naming conventions (snake_case files, PascalCase classes)
- [ ] Use FeedbackHelpers for user feedback
- [ ] Test navigation flows with GoRouter
- [ ] Dispose resources (controllers, listeners)
- [ ] Use theme colors (no hard-coded colors)
- [ ] Check context.mounted before async UI updates

---

**This document should be your first reference for any task in this codebase. When in doubt, check existing code in the same category before making assumptions.**
