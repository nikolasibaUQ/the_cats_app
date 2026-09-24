# CI guide

This document describes the GitHub Actions workflow in
`.github/workflows/dart.yml`. It runs on every push to `main` and every pull
request targeting `main`, validating the same commands documented in
[development.md](development.md).

## Design

Two jobs run in parallel so quality checks and the Android build do not wait
for each other:

| Job | Responsibility | Artifacts |
| --- | --- | --- |
| `quality` | Generation, formatting, analysis, tests, and the Web release build | `coverage`, `web-build` |
| `android` | Android debug build | `the-cats-app-debug-apk` |

Both jobs pin Flutter 3.35.6, the toolchain version used by the Docker build
and local development (see [Toolchain](development.md#toolchain)).

## Generated code

Generated files (`*.g.dart`, `lib/l10n/generated/`) are gitignored and never
committed. Each job therefore runs `flutter gen-l10n` and
`dart run build_runner build --delete-conflicting-outputs` before any other
step; otherwise analysis, tests, and builds would not compile on the clean CI
checkout.

## quality job

The steps, in order:

1. Set up Flutter and run `flutter pub get`.
2. Regenerate localization and Riverpod/JSON code.
3. `dart format --output=none --set-exit-if-changed .` fails the job on
   unformatted files.
4. `flutter analyze --fatal-infos` treats infos as failures.
5. `flutter test --coverage` runs the test suite; the `coverage` artifact
   contains `coverage/lcov.info`.
6. `flutter build web --release --dart-define-from-file=.env.example` builds
   the same production artifact as the Docker image; the `web-build` artifact
   contains the generated site.

## android job

The steps, in order:

1. Set up Flutter and run `flutter pub get`.
2. Regenerate localization and Riverpod/JSON code.
3. `flutter build apk --debug --dart-define-from-file=.env.example` produces a
   debug APK, signed with the automatically generated debug keystore, so no
   signing configuration or secrets are required.
4. The `the-cats-app-debug-apk` artifact contains `app-debug.apk`, installable
   on a physical Android device.

## API key

Builds read `--dart-define-from-file=.env.example`, which contains The Cat
API's public demo key. The key is not a private secret (see
[Credentials and failures](api.md#credentials-and-failures)), so the workflow
uses no GitHub secrets.

## Artifact retention

Artifacts keep GitHub's default 90-day retention. They are downloadable from
the workflow run page under the Actions tab.

## Out of scope

- Signed release APKs: they would require a keystore and GitHub secrets.
- iOS and macOS builds: they require macOS runners.
- Deployment: the hosted flow in [deployment.md](deployment.md) is unchanged;
  CI validates the Web build but does not publish it.
