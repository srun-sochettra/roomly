# Roomly backend

**Laravel 13 REST API for room booking — Sanctum token auth, PostgreSQL, one service that owns every booking rule, and a Blade review panel at `/admin`.**

This backend serves the [Flutter client](../mobile/) and the [Postman collection](../postman/).
Project overview, database diagram and setup steps live in the [repo README](../README.md).

## Layout

| Area | Files |
| --- | --- |
| Mobile API routes | [`routes/api.php`](routes/api.php) |
| Booking rules | [`app/Services/BookingService.php`](app/Services/BookingService.php) |
| Controllers | [`app/Http/Controllers/Api`](app/Http/Controllers/Api) and [`app/Http/Controllers/Admin`](app/Http/Controllers/Admin) |
| Validation | [`app/Http/Requests`](app/Http/Requests) |
| JSON output | [`app/Http/Resources`](app/Http/Resources) |
| Rules guard | [`app/Http/Middleware/EnsureAdmin.php`](app/Http/Middleware/EnsureAdmin.php) |
| Migrations | [`database/migrations`](database/migrations) — `users` (+ `role`), `rooms`, `bookings`, Sanctum tokens |
| Admin panel views | [`resources/views/admin`](resources/views/admin) |
| Tests | [`tests/Feature/BookingRulesTest.php`](tests/Feature/BookingRulesTest.php) |

## Endpoints

| Method | Path | Access |
| --- | --- | --- |
| POST | `/api/register` | public — creates a `student` |
| POST | `/api/login` | public — throttled 10/min |
| GET | `/api/me` | signed in |
| POST | `/api/logout` | signed in |
| GET | `/api/rooms`, `/api/rooms/{room}`, `/api/rooms/{room}/schedule` | signed in |
| GET | `/api/bookings`, `/api/bookings/{booking}` | signed in (own records) |
| POST | `/api/bookings` | signed in — `pending` after the overlap check |
| PATCH | `/api/bookings/{booking}/cancel` | owner |
| POST/PUT/DELETE | `/api/rooms[...]` | admin |
| PATCH | `/api/bookings/{booking}/status` | admin — approve, reject, admin-cancel |

Web routes under `/admin` mirror the review actions with Blade views: login, dashboard,
booking approve / reject / cancel and room CRUD.

## Run

```sh
composer install
cp .env.example .env          # set DB_CONNECTION=pgsql credentials
php artisan key:generate
php artisan migrate
php artisan serve             # http://127.0.0.1:8000
php artisan schedule:work     # optional: minute-by-minute booking expiry
```

Promote an account to admin (see the [repo README](../README.md) for the tinker one-liner) or
insert a user with `role = admin` directly.

## Checks

```sh
php artisan pint     # style
php artisan test     # BookingRulesTest: overlaps, approvals, cancellation limits, expiry
```
