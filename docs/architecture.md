# Architecture

## Scope

The Cats keeps one bounded context: the breed journey (catalog and detail). The
code is therefore organised by layer rather than by feature. With a single
domain, a `features/breeds/` wrapper adds a nesting level without adding
information, and the layer names alone already read as the dependency rule:

```text
lib/
  app/          shell: entry, routing, theme, locale
  domain/       entities, repository contract, domain rules
  data/         mappers, DTOs, sources, repository implementation
  presentation/ flows (splash, catalog, detail): screens, controllers, widgets,
    plus display rules (`presentation/utils/`)
  di/           composition root
  l10n/         generated translations and ARB sources
  shared/       viewport measurements and cross-flow widgets
```

The app shell hosts and wires the application: entry, routing, theme, and
locale. It renders nothing. Every screen — including the splash — belongs to a
presentation flow, where it keeps the same role split as the other flows.

A second bounded context would justify reintroducing the feature wrapper and
nesting these layers under it. Until that exists, the flat structure is the
smallest one that stays honest about its dependencies. Keep the implementation
proportional to this technical challenge.

## Dependencies

Presentation depends on Domain. Data implements contracts owned by Domain.
Domain does not depend on Flutter widgets, Dio, JSON, or The Cat API response
shapes. Riverpod connects the layers and manages UI state.

```text
UI → Riverpod → BreedsRepository ← BreedsRepositoryImpl
                                         ↓
                              BreedsRemoteDataSource → Dio
```

This separation makes parsing and failures testable without a widget tree and
lets the UI work with application concepts rather than API fields. It costs
files and mapping code, so use only pieces that earn their place.

## Suggested structure

```text
lib/
  main.dart
  app/                         # app shell: entry, routing, theme, and locale
    app_theme.dart             # application-wide visual tokens
    app_routes.dart            # route paths shared by the router and screens
    app_router.dart            # GoRouter provider (kept alive)
    app_locale_controller.dart # selected interface language
  di/
    breeds_dependencies.dart   # composition root for concrete dependencies
  presentation/                # one folder per flow, one subfolder per role
    utils/                     # display rules shared by more than one flow
      breed_formatting.dart    # display rules such as the weight system
      photo_framing.dart       # how a photo shapes the frame it fills
    splash/                    # entry flow
      screens/splash_screen.dart         # renders the artwork and hands over
      controllers/splash_controller.dart # times the hand-over
    catalog/                   # list flow
      screens/breeds_screen.dart
      controllers/breeds_catalog_controller.dart  # search and reveal input
      providers/breeds_providers.dart             # cached list and trait state
      providers/breeds_catalog_view_provider.dart # derived results
      widgets/                 # card, header, results sliver
    detail/                    # detail flow
      screens/breed_detail_screen.dart
      providers/breed_detail_providers.dart
      widgets/                 # hero, gallery, information, fact card, panels
  domain/
    entities/                  # Breed, BreedPhoto
    policies/                  # search and gallery image rules
    repositories/              # BreedsRepository contract
  data/
    dtos/                      # JSON shapes returned by The Cat API
    mappers/                   # shared raw-value interpretation (json_values)
    sources/                   # Dio client for /breeds and /images/search
    repositories/              # BreedsRepositoryImpl
  shared/
    utils/                     # viewport measurements (Responsive)
    widgets/                   # widgets used across presentation flows
assets/
  images/                      # responsive loading and unavailable artwork
```

Models stay split by the role they play: entities describe the application,
DTOs describe the payload, and the mapping helpers that turn one into the other
live next to the DTOs. One folder per role keeps the dependency direction
visible from the import path alone.

This is a guide, not a directory checklist. Create folders only when they hold
real responsibilities. Put a widget in `shared/` only when it is actually used
by more than one flow.

Helpers have a home per layer instead of one global folder: domain rules live
in `domain/policies/`, raw-value interpretation in `data/mappers/`, display
rules in `presentation/utils/`, and only layer-agnostic utilities (no domain
or presentation imports) in `shared/utils/`. `shared/utils/` gets a
`utils.dart` barrel only once consumers import more than one of its files.

A presentation flow uses at most four role folders, and a file always lives in
the one named after its suffix: `screens/` for `*_screen.dart`, `controllers/`
for `*_controller.dart` notifiers, `providers/` for derived `*_provider(s).dart`
state, and `widgets/` for reusable widgets. State shared by more than one flow
lives with the flow that owns it: the cached breed list and the reference
traits sit in `catalog/providers/breeds_providers.dart`, and detail imports
them the same way it imports the catalog card. Display rules shared by more
than one flow live in `presentation/utils/`, so the root of `presentation/`
holds only flow folders and `utils/`.

## Responsibilities

- **Presentation flows:** one folder per flow (`splash/`, `catalog/`,
  `detail/`), each splitting its roles into `screens/`, `controllers/`,
  `providers/`, and `widgets/`. Route screens coordinate `AsyncValue`,
  navigation, retries, and responsive composition. They watch state and
  dispatch actions; they do not compute results. The catalog controller owns
  input behavior (debounce, minimum query length, revealed count) and the
  input hint. Detail providers resolve the route ID, load its gallery, merge
  its images, and list the remaining breeds. The splash flow keeps the same
  split: its screen renders while its controller times the hand-over to
  `/breeds`.
- **Naming:** a file states whether it holds logic or UI. Riverpod notifiers
  with mutable interaction state are `*Controller` classes in `*_controller.dart`
  files (`AppLocaleController` for the interface language, `SplashController`
  for the splash timing, `BreedsCatalogController` for catalog input);
  read-only and derived state lives in `*_provider(s).dart`; `*_screen.dart`
  files and `widgets/` folders only render. The language menu lives in
  `shared/widgets` because both the catalog and the detail flows render it,
  and it only renders the options `AppLocaleController` owns.
- **Presentation widgets:** render cards, the photo area, gallery, and
  information sections without owning HTTP, mapping, or route decisions. A card
  reports a tap; the screen decides where it leads. The detail hero frames the
  photo with its own proportion (bounded between 3:4 and 3:2) and carries the
  controls that sit above it, while the information column only scrolls. The
  gallery receives its `AsyncValue` and exposes retry, so pending and failed
  photo requests never replace the images that are already available. Opening
  an external article is a widget concern: the URL is validated in Data, so the
  panel only reports whether the platform declined.
- **Domain:** defines `Breed`, `BreedPhoto`, and the repository
  contract in application terms, plus the rules that do not belong to a display
  layer: `searchBreeds` (name or origin matching) and `mergeGalleryPhotos`
  (primary photo first with deduplication).
- **Data source:** owns Dio, request parameters, response shape validation, and
  DTO deserialization for `/breeds` and `/images/search`.
- **Repository implementation:** maps DTOs into domain objects, interpreting
  weight ranges and usable links at that boundary.
- **Feature composition:** `di/breeds_dependencies.dart` is the only file that
  constructs the remote data source and injects its repository behind the
  Domain contract. Presentation does not import Data.
- **Formatting rules:** `presentation/utils/breed_formatting.dart` owns display
  decisions that depend on the active language, such as reading the imperial
  range in English and the metric one elsewhere, with a fallback to whichever
  range the API supplied. `presentation/utils/photo_framing.dart` owns how a
  photo shapes the frame that shows it, so each rule has one home and one
  test.
- **Routing:** `app_routes.dart` declares each path once; the router and the
  screens that navigate share those values, so a path cannot drift between
  definition and use.

The repository boundary isolates remote data and supports mapping and failure
tests. With both list and gallery operations, the remote data source has a
concrete transport responsibility instead of forwarding one call. The
repository keeps API DTOs out of Domain and Presentation. Do not add a use case
that only forwards repository methods; add one when it contains meaningful
application rules or coordinates multiple operations.

The cached list provider supplies the catalog and lets a direct detail URL
resolve after a fresh browser load. A detail provider selects its breed by
route ID, while a separate provider requests up to eight photos for that breed.
Gallery errors remain local to the image area. Unknown IDs show an unavailable
state without starting an image request.

Navigation uses the route stack: the catalog pushes detail, so returning pops
back to a catalog that kept its scroll position, search text, and state. A
direct visit or a browser refresh has no previous route, so the back action
falls back to the catalog location. Opening a different breed from the
suggestions replaces the active detail instead of stacking another detail.

Search debounce and progressive disclosure are presentation behavior. They do
not justify a use case because neither changes business rules nor coordinates
multiple domain operations. Matching rules are derived from domain functions
instead, and the derived catalog result is resolved by
`breedsCatalogViewProvider` so the screen renders values rather than computing
them.

## Checked against common references

The layout is periodically compared with mainstream Clean Architecture
references (Dribba's Clean Architecture guide, the
`sazardev/flutter_clean_architecture` template). The differences below are
decisions, not gaps:

- **DI container:** the references use GetIt; this project injects with
  generated Riverpod providers from `di/breeds_dependencies.dart`, which is the
  same composition-root role without a second framework.
- **Failures:** the references model failures as `Result<T>` plus typed
  network errors. Riverpod's `AsyncValue` already models
  loading/data/error, and the screens render localized generic states, so a
  second result type would duplicate that lifecycle. Typed failures would be
  introduced the day the UI needs to distinguish them.
- **Use cases:** the references wrap every operation in a use-case class.
  Domain rules live in `domain/policies/` (search matching, gallery merging)
  and are tested without widgets; controllers own interaction state (debounce,
  timing, selection), which is presentation behavior rather than business
  logic. No use case that merely forwards a repository call is added.
- **`core/` folder:** the template groups constants, DI, errors, network, and
  utils under `core/`. This project keeps the same concerns under `app/`
  (shell), `shared/` (cross-flow code), `data/sources/` (Dio), and
  `presentation/utils/` (display helpers), so each folder states its layer
  instead of mixing infrastructure with data access.
- **Immutability:** entities are plain immutable Dart classes. Freezed is not
  added for `copyWith` or equality that no flow needs.
- **Barrels:** adopted where a folder's files are imported together
  (`entities.dart`, `dtos.dart`, one `widgets.dart` per flow). Files inside a
  folder import each other directly; only external consumers use the barrel.
- **Widget size:** widgets stay below ~300 lines. `BreedInformation` was split
  so its overview card (`BreedFactCard`) and section frame (`SectionPanel`)
  are widgets of their own.

## Testing boundaries

Prioritize DTO parsing, mapping, repository success and failure, domain
policies, provider behavior, and critical list-to-detail navigation. Verify a
direct detail route. Test observable behavior rather than file or class
structure. Route tests create their own container and router instead of sharing
process-wide state, and `flutter_test` runs each file in `test/` one at a time.

`test/` mirrors the layers it covers (`domain/`, `data/`, `presentation/`,
`shared/`, including `presentation/utils/`) so the shape of the test suite
stays readable next to `lib/`. A rule that depends only on values, such as the
weight system chosen for a language, is tested without a widget tree.
