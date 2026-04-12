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

# 0.1. 📊 CURRENT PROGRESS STATUS

**Last Updated:** 2026-04-12
**Git Commit:** 1163617 - "Transform Shine car marketplace to AURAE dress rental platform"

### ✅ COMPLETED (Phase 1 - Partial)

1. **Branding**
   - Theme colors implemented (AURAE palette)
   - Android app name: "Aurae"
   - iOS display name: "Aurae"
   - Android package: `com.aurae.app`

2. **New Models Created**
   - `DressListing` (lib/data/models/dress_listing.dart)
   - `BusinessDress` (lib/data/models/business_dress.dart)
   - `RentalBooking` (lib/data/models/rental_booking.dart)

3. **Code Cleanup**
   - No "motorex" references remain
   - UI pages cleaned of vehicle terminology

### ⚠️ IN PROGRESS / TODO

**HIGH PRIORITY:**
1. Fix iOS CFBundleName in Info.plist (line 16: still "motorix_app")
2. Consolidate models: Choose `Listing` OR `DressListing` (currently both exist)
3. Rename providers: `GarageProvider` → `WardrobeProvider`

**MEDIUM PRIORITY:**
4. Rename package: `shine_app` → `aurae_app` (affects all imports)
5. Rename services: `VehicleNotificationService` → `DressNotificationService`

**LOW PRIORITY:**
6. Migrate or remove old models: `UserVehicle`, `VehicleService`
7. Update internal variable names from vehicle terminology

### 🎯 NEXT PHASE: Phase 2 (Model/Provider Consolidation)

Before proceeding to booking system, must complete model consolidation.

---

# 0.2. 🚀 PERFORMANCE & TOKEN OPTIMIZATION

**Token Usage Strategy:**

1. **NEVER read files speculatively**
   - Only read files when explicitly needed for current task
   - Use Grep to find specific patterns before reading full files
   - Use file path limits (offset/limit) for large files

2. **Use targeted searches**
   - Grep with `files_with_matches` mode first
   - Only use `content` mode when you need actual content
   - Use `head_limit` to restrict output

3. **Batch operations efficiently**
   - Group related Bash commands with `&&`
   - Make parallel tool calls in single message when independent
   - Avoid sequential file reads when one Grep can find the answer

4. **Avoid redundant reviews**
   - Trust previous work unless explicitly asked to verify
   - Reference file:line_number format instead of showing code
   - Don't re-read files that were just modified

5. **Model-specific guidance**
   - Current dual-model system: `Listing` (old) + `DressListing` (new) coexist
   - Services/providers still reference old `Listing` model
   - When making changes, prefer modifying `Listing` to match dress domain
   - Only create new files when absolutely necessary

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
