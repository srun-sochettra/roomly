# Security guidance

Roomly is coursework, not a supported release. It runs on plain HTTP on loopback or the LAN
against a local PostgreSQL database. This document is not a security audit.

## Data and transport

- The mobile client talks to the API over cleartext HTTP (`http://10.0.2.2:8000/api` on the
  emulator, a LAN IP on real devices). Do not point it at a public host without adding TLS.
- Sanctum bearer tokens never expire (no expiry is configured). They are revocable through
  logout; prune them server-side with `php artisan sanctum:prune-expired` if needed.
- Login is throttled to 10 attempts per minute; the other auth surfaces are not throttled.
- The admin panel identity is a `role` column on `users`. Registration always creates
  `student` accounts, but nothing stops someone with database access from promoting
  themselves — that is acceptable for a demo, not for a real deployment.
- Session storage, cache and jobs live in the database; the `.env` file and its credentials
  are excluded by the ignore files. Never commit a populated `.env`, a keystore, or a
  Postman environment containing a live token.

## Distribution

Android builds at this stage use the debug signing configuration from the Flutter template.
Review signing, application identifiers and distribution before any store release, and keep
signing keys and `android/key.properties` out of commits.

## Reporting

For ordinary defects, provide the affected screen or endpoint, versions, and a minimal
reproduction. Redact private details from screenshots and logs. For sensitive concerns, use
a verified private maintainer channel if one exists, or ask for one without publishing
sensitive details. No dedicated security address or response deadline is confirmed by this
repository.
