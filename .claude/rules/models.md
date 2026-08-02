# Model Rules

Models live in `lib/data/models/` — one file per model, snake_case filename, PascalCase class.

## Hard Rules

1. **NEVER add a `toJson` that's only used to build a request body.** Services build request maps explicitly. Models exist to parse responses.

2. **NEVER trust a field to be present.** The API evolves; parsing must not throw on a missing or null key. Every optional field gets a nullable type and a fallback.

3. **NEVER cast blindly.** Use `as String?` / `as int?` and coalesce. A hard `as String` on a null crashes the whole page. (This exact mistake caused the old "Invalid response format" bug on the Wardrobe page.)

4. **NEVER map snake_case in the widget layer.** The API returns snake_case keys; models convert them to camelCase Dart fields. Nothing above `data/` should see a snake_case key.

5. **NEVER duplicate a model.** If a screen needs a subset, use the existing model or add a getter — don't create `DressLite`.

## The `fromJson` Pattern

```dart
factory BusinessDress.fromJson(Map<String, dynamic> json) {
  return BusinessDress(
    id: json['id'] as int,
    userIdFk: json['userIdFk'] as String,
    name: json['name'] as String?,
    brand: json['brand'] as String? ?? '',
    status: json['status'] as String? ?? 'active',
    isPublic: json['isPublic'] as bool? ?? false,
    dressPhotoUrls: (json['dressPhotoUrls'] as List?)
            ?.map((e) => e.toString())
            .toList() ??
        const [],
    unresolvedDamageCount: json['unresolvedDamageCount'] as int? ?? 0,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}
```

Required fields (`id`, `brand`, `size`, `condition`, `createdAt`) may cast directly. Everything else is nullable-with-default.

## Current Models

| File | Class | Notes |
|---|---|---|
| `business_dress.dart` | `BusinessDress` | **The main dress model.** Mirrors `user_dresses`. Used by Wardrobe and dress detail. |
| `rental_booking.dart` | `RentalBooking` | A booking on a dress. `dressIdFk`, `renterName`, `renterEmail`, `startDate`, `endDate`, `status`. Has `copyWith`. |
| `dress_damage_incident.dart` | `DressDamageIncident` | One damage event. `resolved`, `isPublic`, `photoUrls`. |
| `booked_range.dart` | `BookedRange` | Availability range for calendars. |
| `cart_item.dart` | `CartItem` | Transient cart row. |
| `business_settings.dart` | `BusinessSettings` | `deliveryOption`, `cleaningBufferDays`. |
| `upcoming_booking.dart` | `UpcomingBooking` | Flattened booking for the profile/schedule widgets. |
| `listing.dart`, `dress_listing.dart` | `Listing`, `DressListing` | **Public Browse-side** representations. Still live. |
| `listing_attribute.dart` | `ListingAttribute` | Dropdown/filter options from `dress_attribute`. |
| `pagination.dart` | `Pagination` | `totalRows`, `totalPages`, `pageNumber`. |
| `user.dart` | `User` | Profile. |

## On "Listing" Naming

`listing.dart` and `dress_listing.dart` are **not** legacy leftovers — they model the public Browse view of a dress. Only the old `/listings` *API routes* and the `dress`/`dress_photo` *tables* were retired (Phase 2, 2026-07-28). Don't delete these models as cleanup.

## Dates

`DateTime` fields parse with `DateTime.parse`. Date ranges use Flutter's `DateTimeRange` (`blockedDateRanges` on `BusinessDress`) — the JSON is a list of `{start, end}` objects, converted in `fromJson`. Format for display with `intl`, never with string slicing.
