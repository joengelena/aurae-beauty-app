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

**Last Updated:** 2026-05-17

### ✅ COMPLETED

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

4. **iOS HTTP Fix**
   - Added `NSAllowsLocalNetworking` to Info.plist so simulator can reach local API over HTTP

5. **API (shine_api) — fully transformed & pushed**
   - All controllers, repositories, routes renamed: vehicle → dress
   - Endpoints: `/user/vehicles` → `/user/dresses`, `/user/vehicle-services` → `/user/dress-bookings`
   - AJV schemas renamed: `postVehicle` → `postDress`, `patchVehicle` → `patchDress`, `postVehicleService` → `postBooking`
   - Types updated: `vehiclePhotoUrl` → `dressPhotoUrl`, `vehicleIdFk` → `dressIdFk`

---

### 🚧 WARDROBE PAGE — CURRENT SPRINT

Build the Wardrobe page (replaces GaragePage) for business owners to manage their dress inventory.

**Step 1 — Service layer** `lib/data/services/`
- [x] Created `dress_services.dart` with all methods:
  - `getAllDresses()` → GET `/user/dresses`
  - `getDressById(id)` → GET `/user/dresses/:id`
  - `addDress(data, imageBytes?)` → POST `/user/dresses` (multipart)
  - `updateDress(id, updates, imageBytes?)` → PATCH `/user/dresses/:id`
  - `deleteDress(id)` → DELETE `/user/dresses/:id`
  - `getBookingsByDressId(id)` → GET `/user/dresses/:id/bookings`
  - `addBooking(data)` → POST `/user/dress-bookings`
  - `deleteBooking(bookingId, dressId)` → DELETE `/user/dress-bookings/:id`
- [x] Added `CacheKeys.dresses`, `CacheKeys.dress(id)`, `CacheKeys.dressBookings(id)` to `constants.dart`

**Step 2 — State management** `lib/logic/`
- [ ] Create `wardrobe_provider.dart` (modelled on `garage_provider.dart`)
  - Uses `BusinessDress` model (already exists)
  - Methods: `fetchDresses()`, `addDress()`, `updateDress()`, `deleteDress()`, `reset()`

**Step 3 — Wardrobe page** `lib/presentation/pages/`
- [ ] Create `wardrobe_page.dart` (rename/restyle from `garage_page.dart`)
  - Grid of dress cards (photo, brand, style, color)
  - FAB → Add dress
  - Pull-to-refresh
  - Empty state, error state

**Step 4 — Dress card widget** `lib/presentation/widgets/wardrobe/`
- [ ] `dress_card.dart` — photo, brand, style, color chip, action menu (edit / delete)
- [ ] `wardrobe_empty_state.dart`

**Step 5 — Add / Edit dress form** `lib/presentation/pages/`
- [ ] `add_dress_page.dart` — form fields: brand, style, color, size, purchaseYear, internalName, notes, optional photo
- [ ] `edit_dress_page.dart` — same form pre-populated

**Step 6 — Dress detail page** `lib/presentation/pages/`
- [ ] `dress_detail_page.dart` — full dress info + list of rental bookings
- [ ] `add_booking_page.dart` — log a rental booking (dressIdFk, typeOfService, serviceDate, renter)

**Step 7 — Routing** `lib/app_router.dart`
- [ ] Add `/wardrobe` route (replace or alias `/garage`)
- [ ] Sub-routes: `/wardrobe/add`, `/wardrobe/:id`, `/wardrobe/:id/edit`, `/wardrobe/:id/add-booking`
- [ ] Register `WardrobeProvider` in `main.dart`

---

### ⚠️ OTHER KNOWN ISSUES (fix when touching related files)

- `CFBundleName` in `ios/Runner/Info.plist` still says "motorix_app" (cosmetic, low priority)
- Both `Listing` and `DressListing` models coexist — consolidate after wardrobe sprint
- `VehicleServices` still calls old `/user/vehicles` endpoints — leave until wardrobe sprint replaces it

**LOW PRIORITY:**
6. Migrate or remove old models: `UserVehicle`, `VehicleService`
7. Update internal variable names from vehicle terminology

### 🎯 NEXT PHASE: Phase 2 (Model/Provider Consolidation)

Before proceeding to booking system, must complete model consolidation.

### 📝 TODAY'S SESSION NOTES (2026-04-12)

**Also worked on:** `shine_api` transformation
- ✅ Renamed all controllers, repositories, routes from vehicle → dress
- ✅ Updated API endpoints: `/user/vehicles` → `/user/dresses`
- ⚠️ **API changes NOT yet committed** - ready to commit
- ⚠️ **Database still needs migration** - tables still named `user_vehicles`, `vehicle_service`

**Coordination needed:**
- Flutter app and API must use matching endpoint names
- Database schema must be updated before API will work
- Both repos transforming in parallel

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
