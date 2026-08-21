# UI & Theming Rules

Full design system: `../../DESIGN.md` (repo root). This file is the enforceable subset.

The feel: **boutique, not backend.** A well-kept dressing room — calm, warm, dress-first. Not a SaaS dashboard, not a loud pink fashion app.

## Hard Rules

1. **NEVER hardcode a color.** Use the named theme values from `utils/theme.dart` or `Theme.of(context).colorScheme`. No `Color(0xFF...)` in a widget file.

2. **NEVER use pure black or cold gray.** `Colors.black`, `Colors.grey`, `#000000` are banned. Text is `themeText` (`#3A2E2A`, warm espresso); secondary text is `themeTaupe` (`#78716C`).

3. **NEVER set `fontFamily` inline.** Poppins is set globally in `appTheme`.

4. **NEVER hardcode spacing.** Use `AppConstants` (`spacingSmall` 8, `spacingMedium` 12, `spacingLarge` 16, `spacingExtraLarge` 64).

5. **NEVER use heavy elevation.** The app is nearly flat — `AppConstants.cardShadowElevation` is `1`. Soft, low-opacity shadows only.

6. **NEVER build a new form field, dialog, or empty state from scratch** without checking `widgets/common/` and `widgets/form_fields/` first.

## Palette (`utils/theme.dart`)

| Name | Hex | Use |
|---|---|---|
| `themePrimary` | `#EADFD8` | Primary surface / secondary in `colorScheme` |
| `themeAccent` | `#F4C6C3` | Accent — buttons, active states |
| `themeAccentInk` | `#AE5751` | Text/icon on accent where contrast is needed |
| `themeBackground` | `#FFF8F6` | Scaffold background |
| `themeText` | `#3A2E2A` | Primary text |
| `themeTaupe` | `#78716C` | Secondary text |
| `themeSage` | `#10B981` | Success |
| `themeRose` | `#F43F5E` | Error / urgent |
| `themePeach` | `#FB923C` | Warning |
| `themeLavender` | `#9333EA` | Info |
| `themeSurfaceMuted` | `#F5EFED` | Muted neutral surface — chip backgrounds, photo placeholders, icon squares |
| `themeBorderMuted` | `#DDD4CF` | Inert edge — disabled buttons, empty photo-upload placeholders. Not for active borders (that's `themePrimary`) |

`themeBlue`/`themeGreen`/`themeRed`/`themeOrange` are aliases kept for older call sites — prefer the named colors above in new code.

`dressColorMap` maps dress color names to swatches. Extend it there, never inline.

## Typography

Set in `appTheme.textTheme` — use `Theme.of(context).textTheme.*`:

`headlineLarge` 28 bold · `headlineMedium` 22 bold · `headlineSmall` 18 w600 · `bodyLarge` 16 · `bodyMedium` 14 · `bodySmall` 12 (taupe)

Aliases onto the same scale, for M3 role names that call sites reach for: `titleLarge` = `headlineMedium`, `titleMedium` = `headlineSmall`, `titleSmall` = 14 w600. **Any role not defined in `appTheme` silently falls back to Flutter's M3 defaults** — off-scale sizes and w500 weights. If you use a new role name, define it in `appTheme` first.

Weights are 400 / 600 / 700 only. `w500` is not in the system (Weight Bridge Rule: adjacent roles differ by ≥200).

## Shape & Layout

- Buttons: `borderRadius: 20`, vertical padding 14, horizontal 24
- Cards: rounded 16–20, elevation 1
- Dress images: `AppConstants.listingImageAspectRatio` (3/4 portrait) — consistent everywhere
- Content max width: `AppConstants.contentMaxWidth` (600)
- Two-column grid breakpoint: `AppConstants.twoColumnBreakpoint` (550)

Web and mobile share one widget tree. Anything full-width must be constrained on wide screens.

## Reusable Widgets — Check Before Building

**`widgets/common/`** — `AppCard`, `AppDialog`, `AppEmptyState`, `LoadingButton`, `ActionMenuButton`, `LabeledFab`, `PasswordField`, `PriceActionBar`, `SelectSingleImage`, `CalendarDateRangePicker`

**`AppCard` is the one card idiom.** White surface, 16px radius, the "Raised" shadow, no border. Never hand-roll a `Container` + `BoxDecoration` for a card surface — the app previously drifted into two competing card styles that way.

**`widgets/form_fields/`** — `StringFormField`, `NumberFormField`, `DecimalFormField`, `DateFormField`, `DropdownFormField`, `AutocompleteFormField`

**`widgets/listing/`** (Browse side) — `ListingTile`, `ListingPreview`, `WatchlistHeartButton`, `InfiniteGrid`, `ImageCarousel`, `FilterBar`, `FilterModalContent`, `FilterSidebar`, `SortSheet`, `RangeFilter`, `AvailabilityCalendar`, `BookingFlowCards`

**`WatchlistHeartButton` is the only favourite/save heart.** Browse and Favourites each had their own and drifted (18px vs 24px, rose vs blush, disc vs no disc). Pass `isSaved` for the filled/outlined state; don't rebuild it.

**`widgets/wardrobe/`** (owner side) — `DressCard`, `BookingCalendar`, `BookingPanel`, `DressActionMenu`, `AttributeDropdownField`, `MultiChipSelector`, `PickerFormField`

**`widgets/scaffold/`** — `AppScaffold`, `AppNavigation`, `TitleAppBar`

## Images

Remote images use `cached_network_image`. Always supply a placeholder and an error widget — R2 URLs can 404 and a bare `Image.network` renders a broken box.

## User Feedback

Use `FeedbackHelpers` (`utils/feedback_helpers.dart`) for snackbars and confirmations rather than raw `ScaffoldMessenger`. Snackbar duration is `AppConstants.snackBarDurationSeconds`.
