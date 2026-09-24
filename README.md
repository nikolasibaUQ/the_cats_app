# The Cats 🐈

<p align="center">
  <img src="assets/images/splash_image.png" width="180" alt="The Cats illustration">
</p>

<p align="center">
  A calm, responsive Flutter app for discovering cat breeds.
</p>

<p align="center">
  <a href="https://docs.flutter.dev/get-started/install"><img src="https://img.shields.io/badge/Flutter-3.35.6-02569B?logo=flutter&logoColor=white" alt="Flutter 3.35.6"></a>
  <a href="https://dart.dev"><img src="https://img.shields.io/badge/Dart-3.9.2-0175C2?logo=dart&logoColor=white" alt="Dart 3.9.2"></a>
  <a href="https://riverpod.dev"><img src="https://img.shields.io/badge/State-Riverpod-00BFA5" alt="Riverpod"></a>
  <img src="https://img.shields.io/badge/Platform-Web%20%7C%20iOS%20%7C%20Android-5C6BC0" alt="Web, iOS and Android">
</p>

> 🧪 **Beta:** the Splash → Breeds → Breed Detail journey, API integration,
> localization, Web routing, and automated checks are implemented.

<p align="center">
  <a href="https://thecats.kobrax.dev"><img src="https://img.shields.io/badge/🚀%20OPEN%20THE%20LIVE%20DEMO-thecats.kobrax.dev-FF7043?style=for-the-badge&logo=googlechrome&logoColor=white" alt="Open The Cats live demo"></a>
</p>

> [!TIP]
> **No installation needed:** [open the deployed app now →](https://thecatsapp.kobrax.dev)

## ✨ Highlights

- 🌎 Spanish and English interface, with system-language and measurement defaults.
- 🔎 Breed catalogue with debounced local search, progressive reveal, refresh,
  and recoverable error states.
- 🖼️ Detail route, gallery, responsive layouts, and intentional
  missing/loading-image states.
- 🧱 Layered structure with Riverpod, Dio, GoRouter, DTO-to-entity mapping,
  and tests across Data, Domain, and Presentation.

## 🧰 Requirements

- [Flutter 3.35.6](https://docs.flutter.dev/get-started/install) (Dart 3.9.2)
- A public The Cat API key. The supplied example uses the public demo key.

## 🚀 Run locally

```bash
flutter pub get --enforce-lockfile
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
cp .env.example .env
flutter run -d chrome --dart-define-from-file=.env
```

`CAT_API_KEY` is build-time configuration, not a secret in a Flutter Web
application. Use only a public/demo key in this client-only project. See the
[API guide](docs/api.md#credentials-and-failures) for the rationale.

## ✅ Verify

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test --coverage
flutter build web --release --dart-define-from-file=.env
```

Run code generation again after changing Riverpod annotations or JSON models.

## 📚 Documentation

| Document | What it covers |
| --- | --- |
| 🧱 [Architecture](docs/architecture.md) | Layer boundaries, dependencies, Riverpod roles, and testing boundaries |
| 🐈 [API](docs/api.md) | Endpoints, payload interpretation, omitted fields, and credentials |
| 🎨 [Design](docs/design.md) | Navigation, responsive behavior, localization, image states, and accessibility |
| 🛠️ [Development](docs/development.md) | Setup, generation, quality checks, and test strategy |
| 🌐 [Deployment](docs/deployment.md) | Flutter Web, Docker/Nginx, cache behavior, and hosting considerations |
| 🤖 [Agent guidance](AGENTS.md) | Shared rules for human and AI-assisted development |

## 🔎 Scope notes

- A direct detail link first loads the breed list, then resolves its ID.
- A selected breed loads up to eight gallery photos; its details remain usable
  if that request fails.
- The free API plan does not supply ratings, traits, alternative names, or a
  Wikipedia URL, so the app deliberately does not model or render them.
