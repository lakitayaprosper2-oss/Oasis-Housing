# Oasis Housing (Flutter)

A property management app: login, houses, tenants, and rent-due tracking
with a payment ledger. This folder is the `lib/` source + `pubspec.yaml`
only — you'll generate the platform (Android/iOS) scaffolding yourself
with the Flutter CLI, since that's specific to your machine and Flutter
version.

## Setup (one-time)

1. Create an empty Flutter project next to this folder's contents:
   ```
   flutter create oasis_housing
   cd oasis_housing
   ```
2. Delete the generated `lib/` folder and `pubspec.yaml` that
   `flutter create` made, and copy in the ones from this delivery
   (the `lib/` folder and `pubspec.yaml` provided here) in their place.
3. Install dependencies:
   ```
   flutter pub get
   ```
4. Run it:
   ```
   flutter run
   ```
   (pick your emulator/device, or `flutter run -d chrome` to try it in
   a browser first)

Demo login: **admin / oasis2026** (changeable from the in-app Settings
screen for the current session).

## What's inside

```
lib/
  main.dart                     entry point, theme + provider setup
  theme/app_theme.dart          colors, typography (Fraunces + Inter via google_fonts)
  models/
    house.dart
    tenant.dart
    payment_record.dart
  state/app_state.dart          in-memory data store + all business logic
  utils/rent_calculator.dart    the rent due-date / overdue / payment math
  widgets/
    sketch_icons.dart           hand-drawn style House/Money/Settings icons
    status_dot.dart             green/red status dot
    house_form_dialog.dart
    tenant_form_dialog.dart
    payment_form_dialog.dart
  screens/
    login_screen.dart
    dashboard_screen.dart       the 3 square tiles
    houses_screen.dart          house list, + New, edit/delete (long-press or ⋮)
    house_detail_screen.dart    tenant list for one house
    tenant_detail_screen.dart   tenant detail, payment history, + Add payment
    rent_due_screen.dart        all tenants across houses, sorted by urgency
    settings_screen.dart
```

## Notes

- **Data is in-memory only** (matches the web version) — it seeds three
  demo tenants on launch and resets when the app restarts. If you want
  it to persist across app restarts or sync across devices, the natural
  next step is wiring `AppState` to a local database (e.g. `sqflite` or
  `hive`) or a backend (e.g. Supabase, like your OasisFarmTz project).
- **File uploads** (rent contracts, payment receipts) use the
  `file_picker` package and store the file's on-device path — nothing
  is uploaded anywhere. If you add real persistence, you'll want to
  copy the picked file into the app's own documents directory so it
  survives the OS clearing temp/cache files.
- **Rent math** lives entirely in `utils/rent_calculator.dart`, ported
  from the web version: there's exactly one live due date (days left
  counts down to it, days overdue counts up after it), and it only
  advances once a cycle is fully paid — early payments don't shift the
  schedule, they just show up as extra days left next cycle.
- The app targets phones/tablets primarily; on very narrow phone
  widths the dashboard tiles stack to a single column automatically.
