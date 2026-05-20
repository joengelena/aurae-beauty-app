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

**Last Updated:** 2026-05-20

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

- [x] Created `wardrobe_provider.dart` — fetchDresses, addDress, updateDress, deleteDress, reset
- [x] Created `dress_detail_provider.dart` — loadDress, loadBookings, addBooking, deleteBooking

**Step 3 — Wardrobe page** `lib/presentation/pages/`

- [x] Created `wardrobe_page.dart` — grid of dress cards, FAB, pull-to-refresh, empty/error states

**Step 4 — Dress card widgets** `lib/presentation/widgets/wardrobe/`

- [x] `dress_card.dart` — photo, brand/style, size+color chips, action menu
- [x] `dress_action_menu.dart` — edit + delete (web and mobile)
- [x] `wardrobe_empty_state.dart`
- [x] `wardrobe_error_state.dart`

**Step 5 — Add / Edit dress form** `lib/presentation/pages/`

- [x] `add_dress_page.dart` — brand, style, size, color, purchaseYear, condition, insurance, photo
- [x] `edit_dress_page.dart` — same form pre-populated from WardrobeProvider

**Step 6 — Dress detail page** `lib/presentation/pages/`

- [x] `dress_detail_page.dart` — full dress info + rental bookings list
- [x] `add_booking_page.dart` — log a rental booking

**Step 7 — Routing** `lib/app_router.dart`

- [x] Added `/wardrobe`, `/wardrobe/add`, `/wardrobe/:id`, `/wardrobe/:id/edit`, `/wardrobe/:id/add-booking`
- [x] Registered `WardrobeProvider` + `DressDetailProvider` in `main.dart`
- [x] Bottom nav index 2 now points to `/wardrobe`
- [x] Fixed post-signin redirect: was `/garage` (triggered `fetchVehicles` → 404), now `/listings`
- [x] Fixed `errorBuilder` redirect: same fix
- [x] Removed `/garage` from `_publicPages`

**Step 8 — Damage Report** `lib/presentation/pages/`

- [x] Optional collapsible "Damage Report" section added to `add_dress_page.dart` and `edit_dress_page.dart`
  - Text area for damage description
  - Multi-photo picker (up to 5 damage photos, with thumbnail + remove button)
  - Edit page pre-populates existing `damageDescription` and shows existing `damagePhotoUrls`
- [x] `BusinessDress` model updated: added `damageDescription` + `damagePhotoUrls` fields
- [x] AJV schema updated: `damageDescription` added to `postDress` and `patchDress`

---

### ⚠️ OTHER KNOWN ISSUES (fix when touching related files)

- `CFBundleName` in `ios/Runner/Info.plist` still says "motorix_app" (cosmetic, low priority)
- Both `Listing` and `DressListing` models coexist — consolidate after wardrobe sprint
- `VehicleServices` still calls old `/user/vehicles` endpoints — leave until wardrobe sprint replaces it

**LOW PRIORITY:** 6. Migrate or remove old models: `UserVehicle`, `VehicleService` 7. Update internal variable names from vehicle terminology

---

### 🎯 NEXT STEPS

#### 1. Database Migration (BLOCKING — API won't work until this is done)

The API code is fully transformed (vehicle → dress) but the DB still has old tables.

Run the following migration SQL:

```sql
-- Rename tables
ALTER TABLE user_vehicles RENAME TO user_dresses;
ALTER TABLE vehicle_service RENAME TO dress_bookings;

-- Rename columns in user_dresses
ALTER TABLE user_dresses RENAME COLUMN make TO brand;
ALTER TABLE user_dresses RENAME COLUMN model TO style;
ALTER TABLE user_dresses RENAME COLUMN year TO purchase_year;
ALTER TABLE user_dresses RENAME COLUMN nickname TO internal_name;
ALTER TABLE user_dresses RENAME COLUMN license_plate TO internal_ref;
ALTER TABLE user_dresses RENAME COLUMN odometer_reading TO rental_count;
ALTER TABLE user_dresses RENAME COLUMN vehicle_photo_url TO dress_photo_url;
-- Drop vehicle-specific columns no longer needed:
-- fuel_type, transmission, odometer_unit, rego_expiry_date, wof_expiry_date

-- Add new dress-specific columns
ALTER TABLE user_dresses ADD COLUMN size VARCHAR(10);
ALTER TABLE user_dresses ADD COLUMN condition VARCHAR(50);
ALTER TABLE user_dresses ADD COLUMN purchase_price INTEGER;
ALTER TABLE user_dresses ADD COLUMN damage_description TEXT;
ALTER TABLE user_dresses ADD COLUMN damage_photo_urls TEXT[];

-- Rename columns in dress_bookings
ALTER TABLE dress_bookings RENAME COLUMN vehicle_id_fk TO dress_id_fk;
```

After migration, also update the dress repository SQL queries to use the new column names.

#### 2. Damage Photos — Backend Support

The Flutter UI collects up to 5 damage photos but the API doesn't yet accept or store them. To complete this:

- Extend `POST /user/dresses` and `PATCH /user/dresses/:id` to accept `damageImages` as multipart files
- Upload them to R2 and store URLs in the `damage_photo_urls` column
- Return `damagePhotoUrls` in the API response
- Update `DressServices.addDress()` / `updateDress()` to send `_damagePhotoBytes` as multipart files

#### 3. Phase 2 — Model/Provider Consolidation

Before building the public booking system:

- Remove or migrate old `Listing` model (consolidate with `DressListing`)
- Remove `VehicleDetailProvider` and `GarageProvider` once confirmed unused
- Remove `VehicleServices` once no pages reference it

#### 4. Phase 3 — Customer Booking Flow

- Browse page: show dress listings to customers
- Booking flow: date picker → availability check → confirm booking → payment (future)
- `BookingProvider` (new) to manage customer-side bookings

### 📝 SESSION NOTES (2026-05-20)

- ✅ Fixed wardrobe not loading: post-signin redirect was `/garage` → triggered `GaragePage.initState()` → `fetchVehicles()` → `/user/vehicles` 404. Fixed to redirect to `/listings`.
- ✅ Fixed signup duplicate-key error: `signUpUserSupabase.ts` used MySQL error code (`ER_DUP_ENTRY` + `sqlMessage`) — updated to PostgreSQL (`23505` + `constraint`).
- ✅ Damage Report UI added to Add/Edit dress forms.
- ⚠️ API changes in `shine_api` not yet committed to git.

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

# 15. Dev Workflow Reminder (IMPORTANT)

**ALWAYS remind the user to run the Flutter web app through the VS Code Run button (not `flutter run` in terminal).**

This ensures the app runs on `http://localhost:8080`, which is the origin whitelisted in the API's `ALLOWED_COOKIE_ORIGINS`. Running on any other port causes CORS errors on the health check and all API calls, showing "Unable to connect to Aurae servers."

✅ Correct: VS Code → Run button (guaranteed port 8080)
❌ Wrong: `flutter run -d chrome` in terminal (random port, CORS fails)

**ALWAYS remind the user of the test user**
EMAIL: elena@test.com
PASSWORD: password

---

# 16. Summary

You are NOT building a new app.

You are:
👉 transforming an existing car app
👉 into a beauty rental platform

Minimal changes. Maximum reuse.
