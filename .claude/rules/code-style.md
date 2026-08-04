# Code Style

Lints come from `flutter_lints` 5.0.0 via `analysis_options.yaml`. **`flutter analyze` must be clean before committing.**

Never suppress with `// ignore:` unless the line carries a comment explaining why.

## Imports — Always `package:`

This codebase uses absolute package imports everywhere (430 of them, zero relative). Match that — **never introduce `../` imports.**

Order: `dart:` → `package:` (external) → `package:shine_app/` (internal).

```dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shine_app/data/models/business_dress.dart';
import 'package:shine_app/logic/wardrobe_provider.dart';
import 'package:shine_app/utils/theme.dart';
```

## Naming

```dart
// Files: snake_case.dart
business_dress.dart, wardrobe_provider.dart, dress_services.dart

// Classes, enums, typedefs: PascalCase
class BusinessDress {}
class WardrobeProvider extends ChangeNotifier {}

// Variables, functions, parameters: camelCase
final rentalPricePerDay = 45;
Future<void> fetchDresses() async {}

// Private members: leading underscore
final _dressServices = DressServices();
void _handleSubmit() {}

// Constants: lowerCamelCase inside a class
class AppConstants {
  static const double spacingLarge = 16;
}
```

Model files are named for the model (`business_dress.dart` → `BusinessDress`). Provider files end `_provider.dart`, services `_services.dart`, pages `_page.dart`.

## No Magic Numbers

Spacing, sizing, breakpoints, and durations come from `AppConstants` (`utils/constants.dart`). Colors and text styles come from the theme — see `ui-and-theming.md`.

```dart
// ❌
const SizedBox(height: 16)
if (width > 550) { ... }

// ✅
const SizedBox(height: AppConstants.spacingLarge)
if (width > AppConstants.twoColumnBreakpoint) { ... }
```

If a value is genuinely one-off and local, a named `const` at the top of the file is fine. An unexplained literal in the middle of a widget tree is not.

## Logging

**Never use `print()`.** There are currently zero in the codebase — keep it that way. Use `debugPrint` and only for non-sensitive operational detail.

```dart
// ❌ never log secret values
debugPrint('Token: $accessToken');
debugPrint('Password: $password');

// ✅ log the event, not the payload
debugPrint('🔄 Token refresh successful');
debugPrint('❌ Request failed: ${response.statusCode}');
```

`ApiClient` follows this already — it logs refresh *status*, never token values. Don't regress it. Never log full response bodies from authenticated endpoints.

## Trailing Commas

Trailing comma on every multi-line argument list and collection. This is what makes `dart format` produce one-arg-per-line output and keeps diffs to the line that actually changed.

```dart
Container(
  width: 100,
  height: 100,
  child: const Text('Hello'),
);

final sizes = [
  'XS',
  'S',
  'M',
];
```

## Comments

- `///` for public APIs, `//` for inline notes
- Explain **why**, not what
- Delete commented-out code — git remembers it

```dart
// ❌ restates the code
// Get the dress name
final name = dress.name;

// ✅ explains the decision
// Fall back to internalName so owners can still identify unnamed inventory
final name = dress.name ?? dress.internalName ?? 'Untitled';
```

## Lints to Fix Immediately

`prefer_const_constructors` · `prefer_const_literals_to_create_immutables` · `avoid_print` · `unused_import` · `prefer_final_fields` · `use_build_context_synchronously`

The last one is the important one — it catches using `context` after an `await` without a `mounted` check. See `widgets.md`.

## Formatting

```bash
dart format lib/
flutter analyze
```
