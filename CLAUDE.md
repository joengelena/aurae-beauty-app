# CLAUDE.md — shine_app (Flutter)

## Core Principle

This is **NOT a new project**. You are transforming an **existing Flutter car marketplace app** into a **beauty rental platform**.

Priority order:
1. Reuse existing code
2. Modify minimally
3. Only build new when necessary

Never:
- Suggest rebuilding from scratch
- Replace architecture
- Introduce new state management

---

## Architecture (DO NOT CHANGE)

- Provider (ChangeNotifier) — required
- Existing 3-layer structure — keep
- ApiClient — keep
- Caching — keep
- Routing — keep

Do not introduce: Riverpod, Bloc, Redux, or new architecture patterns.

---

## Folder Rules

Only rename conceptually:

```
vehicle.dart → dress.dart
listing.dart → dress_listing.dart
garage_provider → wardrobe_provider
```

Do not restructure folders unless absolutely required.

---

## Domain Models

### DressListing

```dart
class DressListing {
  final String id;
  final String title;
  final String brand;
  final String size;
  final String color;
  final double pricePerDay;
  final List<String> imageUrls;
  final String ownerId;
  final List<DateTimeRange> unavailableDates;
}
```

### Booking

```dart
class Booking {
  final String id;
  final String listingId;
  final String userId;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
}
```

---

## Rental Logic

### Availability Rules

A dress is NOT available if:
- Date overlaps with existing booking
- Manually blocked by owner
- Pending approval (if enabled)

### Booking Flow

1. Select dates
2. Validate availability
3. Create booking
4. Block dates

### Status Lifecycle

```
pending → confirmed → active → returned
```

---

## Providers

- **DressProvider** — fetch listings, filtering, pagination
- **WardrobeProvider** — manage owned dresses
- **BookingProvider** (NEW) — create booking, track status

---

## UI / UX Rules

Style: minimal, feminine, premium

**Colors:**
- Primary: `#EADFD8`
- Accent: `#F4C6C3`
- Background: `#FFF8F6`
- Text: `#3A2E2A`

**Constraints:** large images first, rounded cards (16–20), soft shadows, no harsh black, clean spacing.

---

## Reuse Strategy

Always try:
1. Modify existing widget
2. Extend existing logic
3. Only create new if impossible

---

## Naming Rules

- VehicleCard → DressCard
- GaragePage → WardrobePage
- ListingsPage → BrowsePage

---

## How Claude Should Respond

When generating code:
- Be concise
- Modify existing code when possible
- Explain briefly (1–3 lines max)
- Follow current patterns
- Assume existing infrastructure exists
- Match current coding style

Do not: over-explain, rewrite entire files unnecessarily, or suggest unrelated improvements.

---

## Decision Rules

1. Reuse > New
2. Simple > Complex
3. Consistent > "Better"

---

## Summary

You are NOT building a new app. You are transforming an existing car app into a beauty rental platform. Minimal changes. Maximum reuse.
