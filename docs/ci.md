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
| `android` | Android release build | `the-cats-app-release-apk` |

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
3. `flutter build apk --release` produces a release APK. The API key comes
   from the repository secret `CAT_API_KEY` through
   `--dart-define=CAT_API_KEY=…`; when the secret is not available (pull
   requests from forks never receive secrets), the build falls back to the
   public demo key in `.env.example`. `key.properties` and the upload keystore
   are gitignored, so `app/build.gradle.kts` falls back to the automatically
   generated debug signing config on CI; no signing configuration or secrets
   are required.
4. The `the-cats-app-release-apk` artifact contains `app-release.apk`,
   installable on a physical Android device.

## API key

The repository secret `CAT_API_KEY` (GitHub repository settings → Secrets and
variables → Actions) holds the real The Cat API key. The `android` job injects
it into the APK with `--dart-define` and only falls back to the public demo
key when the secret is missing, so fork pull requests still produce a working
artifact. The `quality` job's Web build deliberately keeps the demo key: a
Flutter Web bundle is served to any browser, and a key compiled into it is
visible to every user, so the private key never reaches the public build (see
[Credentials and failures](api.md#credentials-and-failures)). The secret
protects the repository, not the installed artifact: any client binary
necessarily carries the key it uses, on Web and on Android alike.

## Artifact retention

Artifacts keep GitHub's default 90-day retention. They are downloadable from
the workflow run page under the Actions tab.

## Out of scope

- Play Store release signing: publishing requires the upload keystore and
  GitHub secrets. The CI release APK is signed with the debug keystore
  fallback and is not suitable for distribution to the Play Store.
- iOS and macOS builds: they require macOS runners.
- Deployment: the hosted flow in [deployment.md](deployment.md) is unchanged;
  CI validates the Web build but does not publish it.
