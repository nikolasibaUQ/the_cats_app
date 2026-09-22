# The Cats 🐈

A Flutter technical challenge built around [The Cat API](https://thecatapi.com/).
Browse cat breeds, search by name, and open a detail page that also works as a
direct Web link.

> **Beta status:** The three-screen journey and API integration are implemented.
> The release build succeeds locally. Web image handling was verified in a real
> browser for the list, detail, and missing-image cases. Deployment on a host
> still needs review.

## At a glance

| Area | Current beta |
| --- | --- |
| Splash | Entry route moves to the breed list without an extra history stop |
| Breeds | API list, local search, refresh, loading, empty, and error states |
| Detail | Image, description, available traits, and `/breeds/:id` route |
| Languages | Spanish and English UI, with device-language default and in-app selector |
| Web hosting | Dockerfile and Nginx route fallback present |
| Tests | DTO parsing, mapping validation, image strategy, and search-to-detail interaction |

## Use the app

1. Open `/` to enter the breed list through the brief splash.
2. Browse or search by breed name. Select a card to open its detail page.
3. Read the available description and characteristics, then use the back
   action to return to the list. A detail URL can load independently.

The UI uses a warm, restrained style and adapts from mobile to wider Web
layouts. Image loading and failures have visual fallbacks. Because the image
host sends no CORS headers, Web builds render photos through an HTML `<img>`
platform view instead of the canvas; `docs/design.md` explains the constraint
and the chosen strategy. API errors offer retry instead of exposing exception
text. Trait values describe **how much of
a trait** a breed has, not whether that trait is universally good; for example,
high grooming means more care is needed.

The shared [`Responsive` helper](lib/shared/responsive.dart) supplies bounded
spacing, radii, icon sizes, and viewport measurements. The list chooses grid
columns from its available width and scrolls as one page; its header keeps the
section label and the result counter on one line while both fit and wraps them
otherwise. Detail stacks its content on mobile and uses two columns on wide
screens, with the information column scrolling independently. Flutter's text
theme still handles text scaling and accessibility.

The interface follows the device language when it is Spanish or English.
The language button in the app bar also lets users choose **Español**,
**English**, or the system setting for the current session. UI copy lives in
`lib/l10n/app_es.arb` and `lib/l10n/app_en.arb`; `flutter gen-l10n` regenerates
the typed localization classes. Breed names, origins, and descriptions come
from The Cat API in their original language and are not translated locally.

## Architecture and reasons

The app keeps one `breeds` feature for the full journey. Its dependencies flow
through these responsibilities:

```text
Presentation → Domain ← Data → The Cat API
       Riverpod connects state and dependencies
```

- **Presentation** renders `AsyncValue` states, search, navigation, and retry.
- **Domain** defines `Breed` and the repository contract in app terms.
- **Data** uses one configured Dio client, parses immutable
  `json_serializable` DTOs, maps them to `Breed`, and implements the repository
  contract in the same class for this single endpoint.

GoRouter provides addressable routes; generated Riverpod providers manage the
API dependency and cached list state. These boundaries make parsing and
failures testable without putting networking in widgets. There are no
forwarding-only use cases, remote data sources, or empty architecture
directories. Freezed was removed because these DTOs are parsed once and do
not use generated `copyWith` or value equality.

| Decision | Benefit | Cost |
| --- | --- | --- |
| Search the loaded list locally | Immediate results without more requests | Searches only loaded data |
| Resolve detail by ID from the list | Direct URLs work without another endpoint | A fresh detail visit loads the list |
| Map API DTOs to `Breed` | UI does not depend on response shape | Small mapping step |
| Use one Dio configuration | Consistent timeouts and API header | Shared network dependency |

This beta focuses on breed exploration. Favorites, authentication, pagination,
and extra API calls are outside its scope.

## Run locally

Install [Flutter 3.35.6](https://docs.flutter.dev/get-started/install), the
version used by the Docker build (Dart 3.9.2), then run:

```bash
flutter pub get --enforce-lockfile
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
cp .env.example .env
flutter run -d chrome --dart-define-from-file=.env
```

`.env.example` contains the public `DEMO-API-KEY` displayed on The Cat API
website. Edit your ignored `.env` only for local configuration. The Dart code
reads `CAT_API_KEY` from the build definition; it contains no API key. A request
without a key returned HTTP 403 during implementation.

The `.env` file keeps configuration out of Git, but it **does not keep a key
secret in Flutter Web**. The build includes the value in code delivered to the
browser, and the request header is visible in browser developer tools.
Encryption inside the app would also require shipping the decryption key.
Use only the public demo key for this client-only beta. A truly private key
would require a server-side proxy that holds it and enforces limits; this
project does not add that backend for the current challenge.

## Quality checks

```bash
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
flutter analyze
flutter test
flutter build web --release --dart-define-from-file=.env
```

Code generation, analysis, tests, and the Web release build passed locally for
this beta. Tests cover DTO parsing, repository mapping, search-to-detail,
direct detail routes, language switching, and layouts at phone, tablet, and
desktop widths. Repository failure behavior remains a testing priority.

`analysis_options.yaml` enables strict type checks, explicit public API types,
file naming, and checks for dropped asynchronous work. Dart files with one
principal class use its name in `snake_case`; the analyzer enforces the naming
format, while the class-to-file match remains a review convention. Local type
inference is kept where Dart can determine a concrete type.

## Web hosting

The [Dockerfile](Dockerfile) pins Flutter 3.35.6, builds Flutter Web, and serves
it with [Nginx](nginx.conf). Nginx falls back to `index.html` for application routes,
which supports direct links and refreshes once deployed. The Docker image and
hosted route behavior have not yet been verified end to end. Dokploy is a
possible host, not an implemented dependency.

The Docker build uses the public `.env.example` and excludes the local `.env`
from its build context. It never uses a private local key.

Generated Riverpod, JSON, and localization Dart files are ignored by
Git. The Docker build generates them before compiling Web. The shared
[VS Code settings](.vscode/settings.json) hide those files in Explorer and
search results; local launch settings remain private.

## Current limits

- A fresh detail URL fetches the full breed list before selecting its ID.
- 41 of the 107 live breed entries have no image, so the placeholder is common.
- Web photos use an HTML `<img>` platform view because `cdn2.thecatapi.com`
  sends no CORS headers. Such images are not captured by Flutter screenshot or
  `RepaintBoundary` APIs, and colour, opacity, and filter options do not apply
  to them. Mobile and desktop are unaffected.
- Some API entries lack an image or numeric trait ratings. The UI uses a
  fallback image and omits missing ratings. The sampled live response had no
  numeric trait fields.
- The selected interface language resets when the app restarts. API-provided
  content remains in the source language.
- Desktop browser visuals, browser history, and hosted routes still need
  end-to-end review before final submission. The mobile list was reviewed on
  an iPhone simulator; responsive widget tests cover list and detail layouts.
