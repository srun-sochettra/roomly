# Contributing to Roomly

Roomly is a four-person coursework project. Keep changes focused on one layer at a time and
read the [README](README.md) before touching dependencies or the booking rules.

## Where things live

| Folder | Layer convention |
| --- | --- |
| `backend/` | HTTP handling in `app/Http/Controllers`, shared business rules in `app/Services/BookingService`, persistence in `app/Models`, request validation in `app/Http/Requests`, JSON shaping in `app/Http/Resources` |
| `mobile/` | Screens in `lib/screens`, state in `lib/state`, API access only in `lib/services`, reusable UI in `lib/widgets` |
| `postman/` | The collection mirrors `backend/routes/api.php`; keep them in sync |

Do not introduce a new architecture for a small change, and never commit `.env`, keystore
files or anything out of `backend/vendor/` and `mobile/.dart_tool/` — the ignore files already
guard these, so a surprised `git add -f` is the only path to a leak.

## Backend changes

- Validate input in form requests or controller validation, never in Blade views.
- Booking lifecycle changes belong in `BookingService` so the API and the admin panel keep
  enforcing the same rules. Direct `Booking::create(...)` calls outside the service are how
  races and duplicate approvals appear.
- Add a migration for schema changes; do not edit shipped migrations in place.
- Run `php artisan pint` and `php artisan test` before pushing. `BookingRulesTest` should
  still pass; extend it when the rules change.

## Mobile changes

- All HTTP access goes through `lib/services/api_service.dart`. Screens never call `http`
  directly.
- Restore-worthy preferences (theme, session token) are persisted through providers backed
  by `SharedPreferences`.
- Exercise both themes, large text and narrow layouts for UI changes, and the loading, error
  and empty states in `lib/widgets/state_views.dart` for data changes.

## Pull requests

Explain the problem, the focused change, verification and any remaining gaps. Include
screenshots for visual changes but remove private details (user emails, tokens, local IP).
Keep generated builds and unrelated platform changes out of the patch. Follow
[SECURITY.md](SECURITY.md) for anything sensitive.
