# Multi-Profile / Multi-Business — Design

Status: **M1 (data model) and M2 (API) implemented.** M3 (Flutter app — profile switcher,
router rework) and M4 (staff-facing UI) are not started; see Roadmap. Scope for the first pass
is **dress rental only** — the model is shaped to support other categories (hair salon, nail
salon, ...) later, but no category-specific behavior is built until dress rental works end to
end.

---

## Core Concept

One Supabase **account** can hold several **profiles**. A profile is "how you're currently
using the app," and you switch between them without signing out.

```
Account (Supabase Auth user, one `user` row)
 ├─ Customer profile        — implicit, always available, not tied to any business
 ├─ Owner profile @ Business A    — you created Business A
 ├─ Staff profile @ Business B    — you joined Business B via an invite code
 └─ ... any number of Owner/Staff profiles across different businesses
```

- **Customer** is not a row in any table — it's just the default way of using the account
  (browse, cart, book). Every account can act as a customer with zero setup.
- **Owner** and **Staff** are both *memberships in a business* — the only difference is `role`.
  Creating an Owner profile creates a new `business`; creating a Staff profile joins an
  existing one via invite code.
- The **active profile** is which context you're currently in. It's a client-side selection
  (not a new identity/session) — it decides which nav/pages render and which `business_id`
  gets sent with business-scoped requests. The server independently verifies membership on
  every request; the client's "active profile" is a UI convenience, never a trust boundary.

---

## Data Model Changes

### `business` (new table)

Replaces the current situation where `user.is_seller` + `user.business_settings` make the
user itself double as the business.

| Column | Notes |
|---|---|
| `id` | PK |
| `name` | Business display name |
| `category` | enum, only `'dress_rental'` valid for now — column exists so future categories don't require a migration |
| `owner_user_id_fk` | **Founding-owner anchor, not "the current owner."** Set once at creation, UNIQUE, never changes. Its only job is resolving which business a dress belongs to (`business.owner_user_id_fk = user_dresses.user_id_fk`) — dresses are never reassigned, so this anchor is stable regardless of membership changes. Who currently *has* owner access is entirely determined by `business_member.role = 'owner'` rows, independent of this column. |
| `business_settings` | JSONB, moved as-is from `user.business_settings` (`deliveryOption`, `cleaningBufferDays`) |
| `created_at` | |

### `business_member` (new table)

One row per (user, business) relationship. This is what "having a profile" actually means for
Owner/Staff.

| Column | Notes |
|---|---|
| `id` | PK |
| `business_id_fk` | |
| `user_id_fk` | UNIQUE — one business per person, in any role (MVP simplification, see below) |
| `role` | `'owner'` \| `'staff'` — **not unique per business**, a business can have multiple owners |
| `created_at` | |

A user belongs to **at most one business at a time**, in any role — deliberate MVP
simplification, avoids "which business is this request for" ambiguity. A business, however,
**can have multiple owners** (an owner can invite a co-owner, not just staff) — set up this way
from the start since it costs nothing extra and generalizes cleanly to future roles.

### `business_invite` (new table)

Owner-generated, single-use invite. Carries a `role` so it can grant either `'staff'` or
`'owner'` (co-owner) on redemption — not staff-only, hence the generic name.

| Column | Notes |
|---|---|
| `id` | PK |
| `business_id_fk` | |
| `role` | `'owner'` \| `'staff'` — role granted on redemption |
| `code_hash` | sha256 hex of the invite code; plaintext is returned once at creation and never stored |
| `created_by_user_id_fk` | the owner who generated it |
| `status` | `'pending'` \| `'redeemed'` \| `'revoked'` |
| `redeemed_by_user_id_fk` | nullable, set on redemption |
| `redeemed_at` | nullable |
| `expires_at` | 7 days from creation, hardcoded (not user-configurable for MVP) |
| `created_at` | |

The code itself is an 8-character human-typeable string (e.g. `7F3K9QXP`, alphabet excludes
`0/O/1/I/L`) rather than a long link-style token — meant to be read aloud or texted and typed
in, not tapped as a URL. Lower entropy is an accepted tradeoff, mitigated by single-use +
revocable + 7-day expiry.

### `user` table changes

- `is_seller` and `business_settings` **removed** — ownership is now expressed by a
  `business_member` row, and settings live on `business`.
- Migration: every current `user` with `is_seller = true` got one `business` row (name = a
  placeholder boutique name) and one `business_member` row (`role='owner'`). Applied directly
  in `postgresql-db-tool/sql/shine/init/` + seed files (this project resets its dev DB fully
  rather than running incremental migrations, so no separate migration script was needed).
- `deliveryOption` (read via `GET /users/:userId`) still defaults to `'pickup'` for accounts
  with no business, replicating the old column default — this matters because the app's
  onboarding redirect gate reads this field and must keep seeing a non-null value for every
  account, business or not.

---

## Permissions (MVP)

| Action | Customer | Staff | Owner |
|---|---|---|---|
| Browse, cart, book any business | ✅ | ✅ (as themselves, unrelated to their staff business) | ✅ |
| View business's wardrobe/dresses | — | ✅ | ✅ |
| Add / edit / delete dresses | — | ✅ | ✅ |
| Create / confirm / edit bookings | — | ✅ | ✅ |
| View booking calendar / schedule | — | ✅ | ✅ |
| Revenue dashboard | — | ❌ | ✅ |
| View `business_settings` (cleaning buffer, delivery option) | — | ✅ | ✅ |
| Edit `business_settings` | — | ❌ | ✅ |
| Generate / revoke invites (staff or co-owner) | — | ❌ | ✅ |
| Remove a member | — | ❌ | ✅ |

Read access to `business_settings` is deliberately relaxed to include staff (not the strict
blanket ❌ originally sketched here) — implemented this way because `account_menu.dart` calls
`GET /user/settings` unconditionally for any signed-in user today, and reading isn't sensitive.
Write stays owner-only.

Staff gets full **operational** access (wardrobe + bookings), nothing **administrative**
(settings, revenue, staff management). No per-staff granular permission toggles for now —
one fixed `staff` role. Per-staff assignment (e.g. "this booking belongs to this staff
member," relevant once hair/nail salons with individual schedules exist) is explicitly
**out of scope** for the dress-rental pass, since inventory-based rental bookings aren't
naturally owned by one staff member the way an appointment is.

---

## Invite Flow

1. Owner (on their Owner profile) generates an invite via
   `POST /business/:businessId/invites` with `{ role: 'staff' | 'owner' }` — gets an 8-char
   code back once, never persisted in plaintext.
2. Owner sends the code to the invitee out of band (text, email — not built here).
3. Invitee, signed into their own account, redeems it via `POST /business/invites/redeem`
   with `{ code }`.
4. API validates: code hashes to a `pending`, unexpired invite, and the redeeming user doesn't
   already belong to a business → creates `business_member` with **the invite's role** → marks
   invite `redeemed`, stamps `redeemed_by_user_id_fk`.
5. New Owner or Staff profile is immediately active on the account (no Flutter switcher UI yet
   — reachable via curl/Postman until M3).

No pending/approval step after redemption — possession of a valid, unexpired code is the
authorization. Revoking: `DELETE /business/:businessId/invites/:id`, owner-only, only while
still `pending`.

---

## Authorization Model (API) — implemented

Business-scoped resources (dresses, bookings, damage incidents, `business_settings`, invites)
previously resolved "which business" implicitly from `req.body.currentUserId` (there is no
`req.user` in this codebase — `supabaseAuthenticateReq` injects the Supabase user id straight
onto the body), because a user *was* the business. That assumption broke once a user can be
staff at one business and browse as a customer at the same time.

What actually shipped:

- **Existing route paths were kept unchanged** (`/user/dresses*`, `/user/dress-bookings*`,
  `/user/settings`) — only what happens *behind* them changed, so no Flutter changes were
  required for this pass and nothing broke for existing users.
- `businessRepository.resolveOwnerUserIdForMember(userId)` is the seam: given the requesting
  user's id, it resolves their `business_member` row (owner or staff), then that business's
  `owner_user_id_fk` — the id dresses are actually keyed under. Every dress/booking/damage
  controller that used to query by `currentUserId` directly now resolves through this first,
  and 403s with "You don't belong to a business" if the user has no membership at all (new,
  correct gating — previously any signed-in user could hit these routes regardless of role).
  `dressValidation.ts`'s `verifyDressOwnership` was fixed at the source, so every caller that
  already routed through it (`patchDress`, `deleteDress`, all damage-incident controllers)
  needed no changes at all.
- New `/business/*` routes use a parallel helper, `businessValidation.ts`'s
  `verifyBusinessRole(businessId, userId, allowedRoles)`, which checks the `business_member`
  row directly against an explicit `:businessId` route param rather than resolving through the
  dress-ownership anchor.
- There is no "active profile" concept server-side yet — the server always resolves whichever
  single business the user belongs to (enforced by the one-business-per-person UNIQUE
  constraint), so there's no ambiguity to disambiguate until M3 introduces multi-context
  switching in the client.

---

## App-Side Implications (`shine_app`)

- New provider (name TBD, e.g. `ActiveProfileProvider`) holding the list of available
  profiles (customer + each `business_member` row for the signed-in user) and which one is
  currently active. Likely persisted locally (secure storage) so it survives app restarts.
- Profile switcher UI — new, check `widgets/common/` conventions before building.
- New flows: "Create Business" (Owner profile creation — name only, category fixed to
  `dress_rental`), "Join via Code" (Staff profile creation).
- Router (`app_router.dart`) redirect logic currently keys off `is_seller`-style state via
  `ProfileProvider` — needs to key off *active profile type* instead. Wardrobe routes become
  reachable only when the active profile is Owner or Staff on some business; Browse/cart stay
  reachable under a Customer-active profile regardless of what other profiles exist.
- `ApiClient` does **not** need to attach a `business_id` on existing wardrobe/booking/settings
  calls — the server resolves the caller's one business via `business_member` automatically
  (see Authorization Model). A `business_id` only becomes explicit for the new `/business/*`
  routes (owner/staff management, invites), which do take it as a route param.
- Staff gets the existing Wardrobe UI with admin-only actions (settings, revenue dashboard,
  invite management) hidden/disabled per the permissions table above — not a separate UI.

---

## Roadmap

Its own track, orthogonal to the existing numbered Phase 3/4 and lettered Wardrobe A–D work
in the root `CLAUDE.md`. Proposed as **Phase M** (Multi-Profile):

- **M1 — Data model** ✅ done: `business`, `business_member`, `business_invite` tables;
  migration of existing `is_seller` users (including test/base seed data); `dress_bookings`/
  `dress_damage_incidents`/`user_dresses` needed no schema changes at all.
- **M2 — API** ✅ done: business CRUD, invite create/redeem endpoints, `businessValidation.ts`
  role checks, existing dress/booking/settings routes rewired to resolve business membership
  under the hood (same paths, same shapes).
- **M3 — App**: active-profile provider, profile switcher, Create Business / Join via Code
  flows, router redirect rework. Not started.
- **M4 — Staff experience**: role-based hiding of admin-only actions in the existing
  Wardrobe UI; owner-side staff list + revoke. Not started.
- **M5 — Later, explicitly not now**: second business category (hair salon or nail salon) —
  category-specific fields, per-staff appointment assignment/scheduling, granular per-staff
  permission toggles, invite expiry enforcement UI.

Next concrete step when resumed: M3, starting with an active-profile provider in `shine_app`
following the `ChangeNotifierProxyProvider` pattern already used for `ProfileProvider` et al.
