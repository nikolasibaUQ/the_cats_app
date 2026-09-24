# Development guide

This document describes the local workflow for The Cats. Architecture, API
semantics, and UI decisions live in their own documents so this file can stay
focused on building and validating the project.

## Toolchain

The Docker build and local development target Flutter 3.35.6 and Dart 3.9.2.
Use that Flutter SDK version when reproducing a release build.

## Configuration

Create a local `.env` from the checked-in example:

```bash
cp .env.example .env
```

The application reads `CAT_API_KEY` through `--dart-define-from-file`. The
example contains The Cat API's public demo key, which is suitable for this
client-only beta. Do not commit a personal key in `.env`.

An ignored environment file prevents accidental Git commits, but it does not
make a value secret in Flutter Web: the compiled app and request headers are
available to browser users. A private key would require a server-side service;
that is outside this challenge's scope. See [API credentials](api.md#credentials-and-failures).

## First run

```bash
flutter pub get --enforce-lockfile
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
flutter run -d chrome --dart-define-from-file=.env
```

`build_runner` regenerates Riverpod and JSON code. `flutter gen-l10n`
regenerates typed localization classes from `lib/l10n/*.arb`. Generated files
must never be edited manually.

## Everyday checks

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

Use coverage when changing behavior that needs a regression test:

```bash
flutter test --coverage
```

The report is written to `coverage/lcov.info`. Coverage is a signal, not a
reason to add framework-only or otherwise trivial tests. Prioritize parsing,
mapping, repository failures, domain policies, provider state, and meaningful
user interactions.

## Release check

```bash
flutter build web --release --dart-define-from-file=.env
```

Run the Web build after changes to routing, image handling, assets, or
configuration. Deployment-specific behavior is documented in
[deployment.md](deployment.md).

## Test organisation

`test/` mirrors the production layers where that improves discoverability:

| Area | Examples of behavior covered |
| --- | --- |
| Data | DTO parsing, raw-value interpretation, repository mapping, and remote failures |
| Domain | Breed matching and gallery composition policies |
| Presentation | Formatting, providers/controllers, async recovery, navigation, and responsive widgets |
| Shared | Remote-image loading, unavailable states, and common UI behavior |

Tests should describe observable application behavior. Avoid testing Flutter
internals, generated code, or private implementation details merely to increase
the percentage.
