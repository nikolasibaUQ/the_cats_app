# AGENTS.md

## Project

This repository contains a Flutter technical challenge based on The Cat API.

The application consists of three main screens:

Splash
→ Breeds
→ Breed Detail

The objective is to demonstrate solid Flutter engineering practices while keeping
the solution simple, readable, maintainable, testable, and proportional to the
scope of the challenge.

AI-assisted development is allowed, but generated code must meet the same quality
standards as manually written code.

---

## Sources of Truth

Before implementing a task, read the relevant project documentation.

General development rules:
`AGENTS.md`

Architecture and project structure:
`docs/architecture.md`

API behavior and field interpretation:
`docs/api.md`

UI, navigation and interaction requirements:
`docs/design.md`

These documents describe the intended implementation. The README must describe
what is actually implemented at the time of delivery. When documentation and
code differ, determine whether work is pending or a decision changed, then
update the relevant document. Do not silently choose one.

A direct task requested by the developer takes precedence over these documents
when the request explicitly changes an existing decision.

---

## Required Technology Stack

The intended implementation uses:

- Flutter
- Dart
- Flutter Riverpod
- Riverpod code generation with annotations
- Freezed only when generated copyWith or value equality provides value
- json_serializable
- Dio
- GoRouter
- build_runner

Do not replace these technologies unless explicitly requested.

In particular:

Do not use the `http` package.

Networking must use Dio.

Prefer generated Riverpod providers using annotations instead of manually
declared providers where appropriate.

Use Freezed intentionally. Do not create Freezed classes merely because the
package exists.

Use Riverpod's `AsyncValue` for normal asynchronous loading/data/error flows
instead of creating redundant custom loading state classes.

---

## Engineering Principles

Prefer:

clarity
→ correctness
→ maintainability
→ testability
→ simplicity

Avoid architecture or abstractions added only to demonstrate patterns.

This is a technical challenge.

The best solution is not the one with the largest number of layers, classes,
patterns, or packages.

The best solution is the smallest well-structured solution that correctly solves
the requirements and remains easy to evolve.

---

## Code Style and Static Analysis

Follow `analysis_options.yaml` and run `dart format`, `flutter analyze`, and
relevant tests before delivery. Do not suppress a diagnostic without a short
reason tied to an external constraint or a deliberate boundary.

Name Dart files in `lowercase_with_underscores`. When a file has one principal
class, its name should be the class name in snake case: `BreedDetailScreen`
belongs in `breed_detail_screen.dart`. Entry points, route files, and files
that intentionally group related providers or small DTOs may be named for
their responsibility. Keep such groups small and coherent.

File names also state whether they hold logic or UI, and every presentation
flow separates those roles with folders: `screens/` holds route screens,
`controllers/` holds Riverpod notifiers with mutable interaction state,
`providers/` holds read-only and derived state, and `widgets/` holds reusable
widgets. A file lives in the folder named after its suffix (`_screen.dart`,
`_controller.dart`, `_provider.dart`/`_providers.dart`), so the import path
alone already says whether the file is UI or logic. Screens and widgets render
state and dispatch actions only: they do not own timers, debounces, parsing,
or provider state.

A folder whose files are usually imported together may expose a barrel named
after the folder (`widgets.dart`, `entities.dart`) that only re-exports that
folder's public files. Files inside a folder never import their own barrel;
consumers use the barrel only when they need more than one of its files.

Declare parameter and return types on public APIs. Use concrete generic types
and avoid implicit casts from `dynamic`. Local `final` variables may use Dart's
type inference when the resulting type is clear and checked by the analyzer.
Keep `dynamic` at external-data boundaries, validate it there, and do not let
it spread into Domain or Presentation.

Do not add rules that only increase annotations or boilerplate without
catching likely defects in this challenge.

---

## Before Writing Code

Always inspect the existing implementation first.

Before changing a feature:

1. Locate the relevant files.
2. Understand the current implementation.
3. Identify existing patterns.
4. Identify reusable components.
5. Determine the smallest coherent change required.
6. Only then modify the code.

Do not rewrite working code without a clear reason.

Do not modify unrelated files.

Do not introduce speculative functionality.

---

## Architecture

The project follows Clean Architecture, organised by layer. It has a single
bounded context — the breed journey — so a `features/` wrapper would add a
nesting level without adding information. Reintroduce it when a second domain
appears.

The primary layers are:

Presentation
Domain
Data

Dependency direction must preserve domain independence.

Presentation may depend on Domain.

Data implements contracts defined by Domain.

Domain must not depend on Flutter UI, Dio, JSON models, or external API details.

Models stay split by the role they play, inside each layer:

```text
domain/entities/       application models (Breed, BreedPhoto)
domain/policies/       domain rules that are not entities
domain/repositories/   contracts implemented by Data
data/dtos/             payload shapes of the API and bundled assets
data/mappers/          raw-value interpretation shared by the DTOs
data/sources/          Dio client and asset readers
data/repositories/     repository implementations
```

Do not collapse these folders into one flat layer folder: the import path should
state which role a file plays. Keep the number of files in each folder
proportional to what the layer actually needs.

See:

`docs/architecture.md`

Do not create architectural layers only because they appear in traditional
Clean Architecture diagrams.

Use cases are optional.

Create a use case only when it contains meaningful application or business
behavior.

Do not create classes whose only purpose is forwarding a method call without
adding value.

---

## Riverpod

Riverpod is responsible for dependency injection and state management.

Prefer Riverpod code generation.

Providers should expose application dependencies and state cleanly.

Derive ready-to-render state in providers or controllers instead of computing
filtering, search results, or merging inside widgets. A screen should watch
state and dispatch actions.

Widgets should:

- render state;
- dispatch user actions;
- contain presentation logic only.

Widgets must not:

- instantiate Dio;
- perform API requests directly;
- parse JSON;
- contain repository logic.

Prefer `AsyncValue` for asynchronous data.

Always handle:

AsyncLoading
AsyncData
AsyncError

Do not create combinations such as:

`isLoading`
`hasData`
`hasError`

when an explicit state already represents the lifecycle correctly.

---

## Freezed

Use Freezed when generated `copyWith`, value equality, or union states provide
actual value. An immutable DTO parsed once does not require Freezed by default.

Do not automatically use Freezed for every entity or class.

Generated files must never be manually edited.

Never manually edit:

`*.g.dart`
`*.freezed.dart`

Regenerate them using build_runner.

---

## Networking

All HTTP communication must use Dio.

Dio configuration must be centralized in the Data layer. For a single remote
resource, the repository implementation may own the one configured client.
Do not instantiate Dio in screens or widgets, or create a new client per request.

Networking concerns belong in the Data layer.

The expected flow is:

UI
→ Riverpod
→ Repository contract
→ Repository implementation
→ Dio
→ The Cat API

Add a separate remote data source only when it has a distinct responsibility;
do not add one that merely forwards a single request.

API-specific DTOs must not leak unnecessarily into presentation code.

Attributes the provider stops serving may be completed from a bundled dataset
only when its provenance is recorded: the file states its `source` and
`capturedAt`, `docs/api.md` explains why it exists, and a value from the API
always takes precedence over it. Do not invent values, and do not add a second
HTTP provider to fill a gap the chosen API leaves.

See:

`docs/api.md`

---

## Navigation

Navigation uses GoRouter.

Declare route paths once in `lib/app/app_routes.dart` and reuse them from the
router and from the screens that navigate. Widgets report a tap; the screen
decides which route it opens.

Navigation must be functional.

The expected main flow is:

Splash
→ Breeds
→ Breed Detail

Interactive elements that visually suggest navigation must actually navigate.

Web navigation must behave correctly when:

- navigating normally;
- refreshing the browser;
- opening a route directly;
- using browser back navigation.

Do not introduce another navigation package.

---

## UI and UX

The visual direction is:

clean
modern
calm
warm
professional
cat-related

Avoid:

futuristic aesthetics
excessive gradients
glassmorphism
visual noise
unnecessary animations
excessive shadows

Follow `docs/design.md`.

Do not redesign approved UI without being explicitly asked.

Reuse existing UI components before creating new ones.

---

## Responsive Design

The application must work correctly on Flutter Web and common mobile widths.

Do not design only for one fixed resolution.

Prefer Flutter layout primitives and constraints over arbitrary fixed dimensions.

Responsive behavior should remain simple and intentional.

---

## Images

Cat images are remote resources.

Always handle:

- loading;
- failed requests;
- missing URLs;
- different aspect ratios.

Render a placeholder under every photo, so a slow or failed download never
leaves an empty frame. On Flutter Web, photos must use the HTML element strategy
(`WebHtmlElementStrategy.prefer`): reading bytes from the image CDN is blocked by
CORS and logs one error per photo.

An unavailable image must not break the screen.

---

## Error Handling

Failures must produce usable application states rather than crashes.

Handle relevant:

- network failures;
- timeout failures;
- unexpected responses;
- malformed or missing data.

Never show raw exceptions or stack traces to the end user.

Do not silently swallow errors.

---

## Testing

Tests should provide meaningful confidence.

Prioritize testing:

- DTO parsing;
- model/entity mapping;
- repositories;
- state/provider behavior;
- relevant error cases;
- critical user interactions.

Do not create trivial tests only to increase coverage.

Do not test Flutter framework behavior unnecessarily.

---

## Dependencies

Before adding a package, verify that:

1. Flutter/Dart does not already provide the required functionality.
2. An existing dependency cannot already solve the problem.
3. The dependency provides enough value to justify its inclusion.
4. It is actively maintained.

Do not change package versions without a reason related to the task.

---

## Secrets

Never commit secrets.

Do not hardcode:

- passwords;
- private tokens;
- credentials;
- confidential API keys.

Remember that Flutter Web runs on the user's browser.

Values compiled using `--dart-define` into a Flutter Web application must not be
considered secret.

Do not introduce a backend merely to hide a value unless the requirements
actually require one.

---

## Generated Code

After modifying annotated Riverpod, Freezed, or JSON serializable classes, run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Before delivery, run `flutter analyze` and the relevant tests, then update the
README with the actual commands, implemented scope, and known limitations.
