# Roomly mobile

**Flutter student client for Roomly — browse rooms, read the day's timeline, request a slot and track your bookings.**

Pairs with the [Laravel backend](../backend/). Project overview and setup live in the
[repo README](../README.md).

## Screens

Tab navigation is a `NavigationBar` shell that rebuilds the active screen on switch, so data
is always fresh when a tab is reopened.

| Screen | File | What it does |
| --- | --- | --- |
| Login | [`login_screen.dart`](lib/screens/login_screen.dart) | Sign in or register; admin accounts are redirected to the web panel with a friendly message |
| Rooms | [`rooms_screen.dart`](lib/screens/rooms_screen.dart) | Room grid with capacity and type icons |
| Room detail | [`room_detail_screen.dart`](lib/screens/room_detail_screen.dart) | Facts, description and the day timeline for a chosen date |
| Booking sheet | [`booking_sheet.dart`](lib/screens/booking_sheet.dart) | Bottom-sheet form: date, attendees, purpose, time range validation |
| My bookings | [`my_bookings_screen.dart`](lib/screens/my_bookings_screen.dart) | Upcoming / past tabs, cancel action with confirmation |
| Profile | [`profile_screen.dart`](lib/screens/profile_screen.dart) | Account info, theme choice (system / light / dark), logout |

## Structure

| Folder | Contents |
| --- | --- |
| `lib/models/` | `Room`, `Booking`, `AppUser` — parsed from JSON resources |
| `lib/services/api_service.dart` | The only place that touches `http`: Bearer header, 15-second timeout, Laravel validation error flattening, 401 auto-signout |
| `lib/state/` | `AuthProvider` (session resume, token in `SharedPreferences`) and `ThemeProvider` |
| `lib/widgets/` | `day_timeline.dart`, `status_chip.dart`, `state_views.dart` (loading / error / empty) |
| `lib/config.dart` | Base URL selection |
| `lib/theme.dart` | Material 3 themes with Google Fonts |

## Run

```sh
flutter pub get
flutter run
```

`lib/config.dart` picks the API host per target: `http://10.0.2.2:8000/api` for the Android
emulator, or a `--dart-define` override for a real phone on the same Wi-Fi as the backend
laptop:

```sh
flutter run --dart-define=API_URL=http://192.168.1.20:8000/api
```

The backend must be running and reachable; without it the app shows its error states but
still opens, and the last saved session is kept for the next launch.

## Checks

```sh
flutter analyze
flutter test
```
