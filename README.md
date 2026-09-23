# The Cats 🐈

A Flutter technical challenge built around [The Cat API](https://thecatapi.com/).
Browse cat breeds, search by name or origin, and open a detail page that also
works as a direct Web link.

> **Beta status:** The three-screen journey and API integration are implemented.
> The release build succeeds locally. Web image handling was verified in a real
> browser for the list, detail, and missing-image cases. Deployment on a host
> still needs review.

## At a glance

| Area | Current beta |
| --- | --- |
| Splash | Entry route moves to the breed list without an extra history stop |
| Breeds | API list, debounced local search, card with origin and intelligence, progressive reveal, refresh, and complete states |
| Detail | Photo area shaped by the photo it shows, with overlaid controls, the facts the app has (origin, group, life span, weight, height), history, ratings and traits, suggestions, and Wikipedia |
| Languages | Spanish and English UI, with device-language default, in-app selector, and metric/imperial weight |
| Web hosting | Dockerfile and Nginx route fallback present |
| Tests | DTO parsing, mapping, reference-dataset merge and precedence, domain search and gallery rules, weight formatting, provider state, image strategy, and interaction flows |

## Use the app

1. Open `/` to enter the breed list through the brief splash.
2. Browse eight breeds at a time or search the full loaded list by name or
   origin. Select a card to open its detail page.
3. In detail, use the controls over the photo to go back or switch language.
   Swipe through photos, tap one to open the full-screen viewer, and scroll the
   information independently: overview (origin, group, life span, weight,
   height), description, history, characteristics, traits, temperament,
   suggested breeds, and the Wikipedia article. A detail URL can load on its
   own, and going back keeps the catalog exactly as it was left.

The current API response carries the factual fields (description, history,
group, ranges, temperament) but no longer returns the numeric trait ratings, the
binary traits, or a Wikipedia link on the free plan. The app therefore completes
those attributes from a captured dataset that ships with it:
[`assets/breed_reference.json`](assets/breed_reference.json) holds the values for
the 67 breeds that ever carried them, taken from the same `GET /v1/breeds`
response (source and capture date are stored inside the file, and
[`docs/api.md`](docs/api.md) documents the rule). The API always wins attribute
by attribute, so the ratings, traits, and exact article link that appear are the
values The Cat API itself published, and a breed outside the dataset simply
omits those sections instead of inventing numbers. The article action uses
`wikipedia_url` when it exists and otherwise a Wikipedia search for the breed
name, which leads to the article.

The UI uses a warm, restrained style and adapts from mobile to wider Web
layouts. Photos always sit on top of a placeholder that names the breed's
initial, so a slow download, a failed request, or a missing URL never leaves a
blank frame; a breed with no photos says so instead of looking unfinished.
In detail, the photo area adopts the shape of the photo it shows — bounded
between 3:4 and 3:2 — instead of zooming every photo into the same rectangle.
Because the image host sends no CORS headers, Web builds render photos through
an HTML `<img>` element, which is also why the browser console stays clean
instead of reporting one blocked request per photo. API errors offer retry
instead of exposing exception text. Trait values describe **how much of
a trait** a breed has, not whether that trait is universally good; for example,
high grooming means more care is needed.

The shared [`Responsive` helper](lib/shared/responsive.dart) supplies bounded
spacing, radii, icon sizes, and viewport measurements. The list keeps its title
and search field visible while only the results scroll, chooses grid columns
from the available width, initially renders eight cards, and reveals more
without another list request. Detail keeps the photo fixed above the
information on mobile and beside it on wide screens; only the information
area scrolls. Flutter's text theme still handles text scaling and accessibility.

The interface follows the device language when it is Spanish or English.
The language button in the app bar — and over the detail photo — also lets users
choose **Español**, **English**, or the system setting for the current session.
The active language also selects the reading system of the weight: English shows
pounds, the remaining languages show kilograms, and a missing range falls back
to the other one. UI copy lives in
`lib/l10n/app_es.arb` and `lib/l10n/app_en.arb`; `flutter gen-l10n` regenerates
the typed localization classes. Breed names, origins, and descriptions come
from The Cat API in their original language and are not translated locally.

## Architecture and reasons

The app keeps one bounded context — the breed journey — and organises it by
layer, because with a single domain a feature wrapper only adds nesting. Its
dependencies flow through these responsibilities:

```text
Presentation → Domain repository contract ← Data repository
       │                                      │
       └── Riverpod                    remote data source → Dio → The Cat API
                                       reference data source → bundled dataset
```

- **Structure**: `lib/app/` is the shell; `lib/domain/` (`entities/`,
  `policies/`, `repositories/`), `lib/data/` (`dtos/`, `mappers/`, `sources/`,
  `repositories/`), and `lib/presentation/` are the layers; `lib/di/` holds the
  composition root; `lib/shared/` holds what more than one flow uses; and
  `assets/` holds the bundled reference dataset. Models are split by role, so an
  import path already states whether it reads an application entity, a payload
  shape, or a mapping helper. `test/` mirrors those layers. Introducing a second
  domain would justify nesting the layers under a feature folder.
- **Presentation** is grouped by `catalog` and `detail`; the splash entry
  belongs to the app shell because it uses no breed state. Route
  screens coordinate `AsyncValue`, navigation, and retries; generated Riverpod
  providers own search input state, the derived catalog result, breed
  selection, gallery loading, and the suggested breeds. Screens render values,
  they do not compute them, and no widget parses JSON, builds a route string,
  or owns HTTP. Opening an external article is the one platform call a widget
  makes, from the panel that offers it.
- **Domain** defines `Breed`, `BreedPhoto`, `BreedFlag`, and the repository
  contract in app terms, with no Flutter, Dio, or JSON dependency. Name/origin
  matching (`searchBreeds`) and gallery composition (`mergeGalleryPhotos`)
  live here because they are rules rather than drawing code.
- **Data** keeps Dio and response parsing in a remote data source. It also owns
  the interpretation of raw API values: ratings outside 1–5 become unknown,
  binary traits become typed values, and unusable links are dropped. A second
  source reads `assets/breed_reference.json`, the captured dataset of attributes
  the free plan no longer serves, and the repository merges it with the API
  response under one rule: an API value always wins.
- **Composition root** (`lib/di/`) is the only place that constructs the
  concrete Data implementation behind the Domain contract.
- **Display rules** that depend on the active language, such as the weight
  system, live in `lib/presentation/breed_formatting.dart` and are tested
  without a widget tree.
- **Routing** declares each path once in `lib/app/app_routes.dart`, shared by
  the GoRouter provider and the screens that navigate. Detail is pushed on top
  of the catalog, so returning restores it instead of rebuilding it.
- **Shared widgets** contain only what several flows render: images, state
  messages, section titles, rating dots, and the surface used by controls that
  float over a photo.

GoRouter provides addressable routes; generated Riverpod providers manage the
API dependency, cached list state, and the derived search result. These
boundaries make transport, mapping, state derivation, and UI behavior testable
without putting networking in widgets. A use case would only forward repository
methods here, so it is not included. Freezed is unnecessary because these DTOs
are parsed once and do not need generated `copyWith` or value equality.

| Decision | Benefit | Cost |
| --- | --- | --- |
| Debounce local search by 350 ms | Stable typing and no search requests | Results wait briefly after typing |
| Derive matches in a provider | Screens render values and the rule is testable without widgets | One more provider to follow |
| Reveal eight loaded breeds at a time | Shorter initial page without API churn | User chooses when to show more |
| Resolve detail by ID from the list | Direct URLs work without another endpoint | A fresh detail visit loads the list |
| Load up to eight photos for the selected breed | Focused carousel without one request per list card | Detail performs one extra request |
| Keep search and gallery fixed | Query and selected photo remain visible | Less result space on short screens |
| Map API DTOs to `Breed` | UI does not depend on response shape | Small mapping step |
| Isolate Dio in a remote data source | Transport and parsing have one boundary | One additional data class |
| Push detail on top of the catalog | Going back restores scroll, search, and state instead of rebuilding the screen | Navigation has to handle a direct visit that has no history |
| Read the weight in the language's system | Each reader sees the measurement they use | One display rule with a fallback |
| Open the Wikipedia article outside the app | The full article without embedding a browser | One more dependency (`url_launcher`) |
| Suggest six related breeds with a counter | Keeps browsing local to the page | One derived provider |
| Show every rating and trait the API or the reference dataset has | The detail answers most questions without another source | A longer column to scan |
| Bundle the attributes the free plan stopped serving | Real vendor values for the ratings, traits, and article link | A captured dataset to refresh if The Cat API changes it |
| Render each fact once, in the overview cards | The column scans faster and no value appears twice | The header carries only the name and its alternatives |
| Prefer the HTML element for Web photos | No blocked request and no repeated CORS error per photo, plus browser caching | Platform-view images are not captured by screenshot APIs |
| Keep a placeholder under every photo | Loading and failures never leave a blank frame | One extra widget per image |
| State when a breed has no photos | The empty area reads as intentional instead of unfinished | One more localized string |
| Shape the detail photo area to the photo | No photo is zoomed just to fill a fixed rectangle | The area changes size between photos, within a bounded band |

The API supports server pagination. This beta keeps one full-list request so
search covers all breeds and direct detail routes reuse the same cached data;
the list uses local progressive disclosure instead. Detail calls
`/images/search` once with the selected `breed_ids` value and a limit of eight.
Gallery failure does not hide the breed information or its primary image.
Favorites and authentication are outside its scope. The detail column renders
only the sections whose values the API supplied, so breeds with fewer fields
show a shorter page rather than empty placeholders.

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

Code generation, analysis, 54 widget and unit tests, and the Web release build
passed locally for this beta. Tests cover DTO parsing and the interpretation of
raw API values (ratings, binary traits, weight ranges, and usable links), the
shipped reference dataset and its merge rule (an API value always wins, and a
dataset that cannot be read leaves the API data untouched), repository and
gallery request mapping, domain name/origin matching, gallery image
composition, weight formatting per language, the derived catalog
view (reveal count, minimum-length hint, debounce, and clearing), a gallery
failure at provider level, the fixed search area, progressive reveal without
refetching, the splash handing over to the catalog on its own, search-to-detail,
the full-screen photo viewer, the photo strategy and placeholder, the no-photo
state, direct detail
routes, language switching, every detail section rendered exactly once,
related-breed navigation, the
catalog keeping its state when detail is closed, and layouts at phone, tablet,
and desktop widths. Repository failure behavior remains a testing priority.

`analysis_options.yaml` enables strict type checks, explicit public API types,
file naming, and checks for dropped asynchronous work. Dart files with one
principal class use its name in `snake_case`; the analyzer enforces the naming
format, while the class-to-file match remains a review convention. Local type
inference is kept where Dart can determine a concrete type.

## Web hosting

The [Dockerfile](Dockerfile) pins Flutter 3.35.6, builds Flutter Web, and serves
it with [Nginx](nginx.conf). Nginx falls back to `index.html` for application routes,
which supports direct links and refreshes once deployed. The Docker image itself
has not been built here; the release build it produces was verified separately
(see below). Dokploy is a possible host, not an implemented dependency.

A release build was served locally and driven through the Chromium DevTools
protocol at 1280×900 to check what a real browser does: `/` reached `/#/breeds`
on its own, photos rendered, and the console reported zero blocked requests and
zero uncaught errors on the catalog and on a detail page (the same run before
the image strategy change reported six CORS-blocked requests).

Flutter Web registers a service worker that caches the compiled assets. A
browser that already visited the app can keep serving the previous
`main.dart.js` after a redeploy, which looks like an application bug (for
example, a splash screen that never advances). Reload with cache disabled, or
clear the site data once, before diagnosing behavior on a hosted build.

The Docker build uses the public `.env.example` and excludes the local `.env`
from its build context. It never uses a private local key.

Generated Riverpod, JSON, and localization Dart files are ignored by
Git. The Docker build generates them before compiling Web. The shared
[VS Code settings](.vscode/settings.json) hide those files in Explorer and
search results; local launch settings remain private.

## Current limits

- A fresh detail URL fetches the full breed list before selecting its ID.
- Opening a valid detail performs one additional request for up to eight breed
  photos; if it fails, the primary photo and information remain available.
- 41 of the 107 live breed entries have no image, so the placeholder is common;
  that state names the breed's initial and the detail area states that no photo
  is available.
- Web photos use an HTML `<img>` element because `cdn2.thecatapi.com` sends no
  CORS headers. Such images are not captured by Flutter screenshot or
  `RepaintBoundary` APIs, and colour, opacity, and filter options do not apply
  to them. Mobile and desktop are unaffected.
- Web images wait for the browser to paint them, so a photo can appear a moment
  after its card; the placeholder underneath covers that moment instead of
  leaving the frame empty.
- The bundled reference dataset covers 67 of the 107 live breeds, the ones that
  ever carried the ratings. A breed outside it shows the factual fields and omits
  the characteristics and traits sections instead of inventing values.
- The reference dataset is a capture, not a live call: if The Cat API changes
  its values, the file has to be refreshed. Its `source` and `capturedAt` fields
  record where it came from.
- The selected interface language resets when the app restarts. API-provided
  content remains in the source language.
- Desktop browser visuals were reviewed through a locally served release build
  in Chromium, which also covered the splash hand-over and the catalog and
  detail layouts at 1280×900. The hosted deployment, the Docker image, and
  touch gestures on a real phone still need review before final submission. The
  mobile list was reviewed on an iPhone simulator; responsive widget tests cover
  list and detail layouts.
