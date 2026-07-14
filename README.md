# Shine — Flutter App

**Role in the monorepo:** The UI layer. Every screen, every interaction, every visual component lives here.

---

## How this fits into the monorepo

Shine is made of three projects that each own a distinct layer:

| Project | Layer | Responsibility |
|---|---|---|
| `shine_app` ← you are here | UI | Every screen and user interaction |
| `shine_api` | API | All business logic, auth, and data operations |
| `postgresql-db-tool` | Database | Schema definitions, seeding, migrations |

The app talks **only to `shine_api`** — never to the database directly. The API is the single source of truth for all business rules. If the API returns it, display it. Don't second-guess or re-derive it in the app.

---

## What lives in this project

- Screens and widgets (all UI)
- Provider state management (ChangeNotifier)
- API client — the single boundary where HTTP calls are made
- Local UI state (loading, error, form input)
- Lightweight UI-level form validation (the API always validates too)

## What does NOT live in this project

- Business rules → `shine_api` owns these
- Data transformation logic → the API returns ready-to-display data
- Authentication logic → Supabase Auth is handled by the API; the app stores tokens only
- Database knowledge → the app has no concept of tables or columns
- Image upload orchestration → handled by `shine_api` (Cloudflare R2)

---

## Protocols

### Don't duplicate logic
If the API returns a formatted price, rental status, or availability flag — display it. Don't re-implement the same logic in a Provider or widget. Duplication here means two places to change when rules evolve.

### One Provider per domain
`WardrobeProvider`, `BookingProvider`, `BrowseProvider` — one per concern. Don't create multiple providers that manage the same data, and don't put unrelated state together in one provider.

### All API calls go through ApiClient
No widget or provider makes raw HTTP calls. Every network request passes through the `ApiClient` data layer. This is the single seam between UI and API — keep it clean.

### Mirror the API's data model
Flutter models (`BusinessDress`, `RentalBooking`, etc.) should reflect what the API returns — not invent their own shape. When the API schema changes, update the model here to match.

### No magic strings or hardcoded IDs
Dress statuses, booking types, listing types — these live in constants or come from the API. Don't scatter string literals through widgets.

### Don't restructure the architecture
Provider + 3-layer structure (UI → Provider → ApiClient) is fixed. Don't introduce Riverpod, Bloc, or new patterns. Extend what exists.

---

## Design system

Style is defined in `DESIGN.md` at the repo root. The short version:

- **Background:** Petal White `#FFF8F6`
- **Accent:** First Blush `#F4C6C3` — used sparingly (≤15% of any screen)
- **Text:** Warm Espresso `#3A2E2A` — never pure black
- **Font:** Poppins throughout
- **Cards:** 16px radius, white surface, soft shadow
- **Tone:** Minimal, feminine, premium — boutique, not SaaS

Dress photography is the hero of every content screen. Form fields exist to support the dress, not the other way around.

---

## Dev workflow

**Always run via VS Code Run button.** This guarantees port 8080, which is the only origin whitelisted in the API's `ALLOWED_COOKIE_ORIGINS`. Running on any other port breaks auth cookies on every API call.

After any schema change in `postgresql-db-tool`, run `npm run seed` there first, then restart `shine_api`. The app doesn't need changes unless a new field appears in the API response — update the model if so.

**Test user:** `elena@test.com` / `password`
