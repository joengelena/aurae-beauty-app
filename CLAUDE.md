# CLAUDE.md — AURAE Beauty Rental App (STRICT DEVELOPMENT GUIDE)

This file is a **persistent instruction set for Claude**.
Follow ALL rules unless explicitly told otherwise.

---

# 0. 🔴 CORE PRINCIPLE (MOST IMPORTANT)

This is **NOT a new project**.

You are transforming an **existing Flutter car marketplace app** into a **beauty rental platform**.

👉 PRIORITY ORDER:

1. **Reuse existing code**
2. Modify minimally
3. Only build new when necessary

❌ NEVER:

- Suggest rebuilding from scratch
- Replace architecture
- Introduce new state management

---

# 1. Project Overview

**App Name:** AURAE
**Type:** Beauty rental marketplace
**Platform:** Flutter (iOS / Android / Web)

### Users

- **Users** = business owners (list items/services)
- **Customers** = renters

---

# 2. Core Features

## Listings (Browse)

- Browse dress listings
- Filter by:
  - date availability
  - size
  - color
  - price

- View details:
  - images
  - description
  - availability
  - owner info

---

## Booking / Rental

- Select date range
- Validate availability
- Book item
- Payment support (future-ready)
- Choose:
  - pickup OR delivery

- Messaging between user & customer

---

## Wardrobe (Inventory)

Business owners can:

- Add dresses
- Edit listings
- Manage availability
- View renters

---

## User System

- Supabase Auth (KEEP)
- Profile management

---

## Notifications

- Booking reminders
- Return reminders

---

# 3. 🔁 Concept Mapping (MANDATORY)

| OLD SYSTEM      | NEW SYSTEM     |
| --------------- | -------------- |
| Vehicle         | Dress          |
| Listing         | DressListing   |
| Garage          | Wardrobe       |
| Service History | Rental History |
| WOF/Rego        | Booking/Return |

👉 Always translate concepts instead of recreating logic.

---

# 4. Architecture (DO NOT CHANGE)

- Provider (ChangeNotifier) → REQUIRED
- Existing 3-layer structure → KEEP
- ApiClient → KEEP
- Caching → KEEP
- Routing → KEEP

❌ DO NOT introduce:

- Riverpod
- Bloc
- Redux
- New architecture patterns

---

# 5. Folder Transformation Rules

Only rename conceptually:

```
vehicle.dart → dress.dart
listing.dart → dress_listing.dart
garage_provider → wardrobe_provider
```

👉 DO NOT restructure folders unless absolutely required

---

# 6. Domain Models

## DressListing

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

---

## Booking

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

# 7. Rental Logic (STRICT)

## Availability Rules

A dress is NOT available if:

- date overlaps with existing booking
- manually blocked by owner
- pending approval (if enabled)

---

## Booking Flow

1. Select dates
2. Validate availability
3. Create booking
4. Block dates

---

## Status Lifecycle

```
pending → confirmed → active → returned
```

---

# 8. Providers

## DressProvider

- fetch listings
- filtering
- pagination

## WardrobeProvider

- manage owned dresses

## BookingProvider (NEW)

- create booking
- track status

---

# 9. UI / UX Rules (STRICT)

Style:

- minimal
- feminine
- premium

### Colors

- Primary: #EADFD8
- Accent: #F4C6C3
- Background: #FFF8F6
- Text: #3A2E2A

### UI Constraints

- large images FIRST
- rounded cards (16–20)
- soft shadows
- NO harsh black
- clean spacing

---

# 10. Reuse Strategy (CRITICAL)

ALWAYS try:

1. Modify existing widget
2. Extend existing logic
3. Only create new if impossible

---

# 11. Naming Rules

- VehicleCard → DressCard
- GaragePage → WardrobePage
- ListingsPage → BrowsePage

---

# 12. Feature Roadmap

Claude MUST follow phased development:

### Phase 1

- UI transformation

### Phase 2

- rename models/providers

### Phase 3

- booking system

### Phase 4

- notifications

---

# 13. 🔥 HOW CLAUDE SHOULD RESPOND (VERY IMPORTANT)

When generating code:

✅ DO:

- Be concise
- Modify existing code when possible
- Explain briefly (1–3 lines max)
- Follow current patterns

✅ ALWAYS:

- Assume existing infrastructure exists
- Match current coding style

❌ DO NOT:

- Over-explain
- Rewrite entire files unnecessarily
- Suggest unrelated improvements

---

# 14. Decision Rules

If unsure:

1. Reuse > New
2. Simple > Complex
3. Consistent > “Better”

---

# 15. Summary

You are NOT building a new app.

You are:
👉 transforming an existing car app
👉 into a beauty rental platform

Minimal changes. Maximum reuse.
