# The Cat API

## Data source

The base URL is `https://api.thecatapi.com/v1`. The beta uses `GET /breeds` and
`GET /images/search?breed_ids=:id`; the base URL and timeouts are configured in
one Dio client. The breeds endpoint also
accepts `limit` and `page`, and the API exposes `/breeds/search` for remote
name searches. The current scope deliberately keeps one full-list request:
local search must cover every loaded breed and direct detail routes already
resolve from that shared list. The UI reduces visual length by revealing eight
items at a time without making additional list requests.

Breed detail requests up to eight static medium-size photos from
`/images/search`, filtered by the selected breed ID. The endpoint documents a
maximum limit of 25 with an API key and supports `page` plus ordered results.
The current gallery needs only its first bounded set, so it does not paginate.
The breed's primary image is deduplicated against the search response and stays
available while the gallery loads or if that request fails.

The public `DEMO-API-KEY` is shown on The Cat API website and included in
`.env.example`. Local development copies that template to an ignored `.env`
and passes it with `--dart-define-from-file=.env`. The Dart source has no key
fallback. An unauthenticated request returned HTTP 403 during implementation;
the public demo key returned the breed list. A Web build and its outgoing
request headers expose the configured key, so no private credential belongs
in this client-only application.

The list response supplies the breed list and detail page. The detail route
identifies a breed by `id`. On a fresh load, fetch the list and find that ID.
An empty API list has a list empty state; an absent ID has a detail unavailable
state. Malformed or missing required data produces a controlled error.

## Live response shape

Verified against `GET /v1/breeds` with the demo key (107 breeds). Each breed
returns `id`, `name`, `description`, `temperament`, `origin`, `country_code`,
`country_codes`, `life_span`, `weight` and `height` (each with `imperial` and
`metric`), `breed_group`, `history`, `image`, `reference_image_id`, `species_id`,
and null-able `bred_for` and `perfect_for` (null for every breed in that
response). `breed_group` is not listed in the public reference pages, but the
free-plan response carries it for 100 of the 107 breeds (e.g. `Short-haired`,
`Semi-longhair`); the overview simply omits the group card for the breeds that
lack it (`Caracat`, `Dwelf`, `Elf Cat`, `Kellas Cat`, `Napoleon Longhair`,
`Pantherette`, `Singapura Tabby`). `GET /breeds/search` and `GET /breeds/:id`
return the same shape. The `image` object carries `id`, `url`, `width`, and
`height` — verified on the live list, where every one of the 66 breeds with an
image states the size. The detail photo area uses that size to frame the photo
with its own proportion.

The free-plan response **does not** contain the numeric trait ratings
(`adaptability`, `affection_level`, …, `vocalisation`), `alt_names`,
`wikipedia_url`, or the binary trait flags (`indoor`, `lap`, …,
`experimental`), even though the public documentation still describes them.
The application therefore completes the ratings and traits from
`assets/breed_reference.json`, a bundled dataset captured from this same API
before the free plan stopped serving those fields (see
[Ratings and the bundled reference dataset](#ratings-and-the-bundled-reference-dataset)).
`alt_names` and `wikipedia_url` stay unmapped: the article action always opens
a Wikipedia search for the breed name.

## Product fields

| Use | Candidate fields | Handling |
| --- | --- | --- |
| Identity and search | `id`, `name`, `origin` | Require valid identity; filter locally by name or origin, ignoring case. |
| List card | `name`, `origin`, `image.url` | Show the available text and an image fallback. |
| Detail | `origin`, `description`, `history`, `breed_group`, `life_span`, `temperament`, `weight.imperial`, `weight.metric`, `height.imperial`, `height.metric` | Omit missing optional values instead of rendering empty fields. |
| Article | — | The free plan never supplies `wikipedia_url`, so the action always opens a Wikipedia search for the breed name. |
| Gallery | image search `id`, `url`, `width`, `height` | Require an absolute URL, deduplicate it, and isolate gallery failures. |
| Photo framing | `image.width`, `image.height` (and the search's `width`, `height`) | Keep positive sizes only; the detail photo area frames the photo with its own proportion instead of scaling it into a fixed rectangle. |

The approved detail layout decides which of these appear and in what order. It
shows the origin, life span, weight, and height in an overview row, the
temperament words as pills, and the Wikipedia article as a closing action. API
DTOs remain in Data; presentation receives application-friendly values.
`image.url` and `reference_image_id` may not supply a usable image. An image
failure or missing URL must not fail the whole view. The additional image
request supplies the detail carousel and is never performed for list cards.

Fields such as `country_code`, `cfa_url`, `vetstreet_url`, `vcahospitals_url`,
`venom_codes`, `reference_image_id`, `alt_names`, and `wikipedia_url` stay
unmapped: the origin already expresses the country in readable form, the
remaining links duplicate what the article button offers, and the free plan
never returns the others, so mapping them would add code for values nothing
can ever render. The 1–5 ratings and the binary trait flags are the exception:
they come from the bundled reference dataset described below.

## Ratings and the bundled reference dataset

The public documentation still describes the 1–5 ratings (`adaptability`,
`affection_level`, `energy_level`, `grooming`, `health_issues`,
`intelligence`, `shedding_level`, `social_needs`, `vocalisation`, and the
friendly levels) and the binary trait flags. The free-plan response verified
above returns none of them. Instead of inventing values per breed, the
application ships `assets/breed_reference.json`, a dataset captured from this
same API on 2026-09-22, before the free plan stopped serving those fields.
The file records its `source` and `capturedAt`, and `docs/api.md` (this
document) explains why it exists.

The trial scope maps a focused set per breed: five ratings
(`energy_level`, `affection_level`, `intelligence`, `grooming`,
`social_needs`) and three binary traits (`hypoallergenic`, `rare`, `lap`),
stated explicitly as true or false. Entries for breeds the historic capture
does not include (the API listed 107 breeds on 2026-09-25 against 67 captured
ones) are curated from the closest related breed and carry
`"estimated": true` in the file, so a reader can tell a captured measurement
from a curated estimate. A value from a live API response always takes
precedence over the dataset; the free plan currently supplies none of these
fields, so no conflict can arise. Should the plan change or a richer key be
adopted, map each field at the Data boundary and keep the live value first.

The dataset is read once per application run through
`BreedReferenceSource`; the detail screens hide the two trait sections when a
breed has no entry, so a missing reference never replaces breed information
the API already supplied.

## Weight and height

`weight` and `height` state an `imperial` and a `metric` range as text, in pounds
and inches or kilograms and centimetres. Show the range that matches the reading
system of the active language: English reads the imperial range, the remaining
languages read the metric one, and a missing range falls back to the other one
with its own unit. Never parse a range as a single number or invent a more
precise value.

## External articles

The free plan never supplies `wikipedia_url`, so the article action always
opens a Wikipedia search for the breed name; the search resolves directly to
the article, so no guessed article URL is ever built. The link opens outside
the application (a new browser tab on Web) through `url_launcher`. A platform
that refuses to open the link reports it to the user instead of failing
silently.

## Credentials and failures

Browser-delivered configuration, including values from `.env` passed through
`--dart-define-from-file`, is visible to users. Ignoring `.env` protects the
repository, not the compiled Web app. For the same reason the Web build never
receives the private key: it keeps the public demo key, because anything
compiled into a Web bundle is readable by every visitor.

The Android build is the one place the private key is used. CI reads it from
the repository secret `CAT_API_KEY` and injects it into the APK at build time
with `--dart-define` (see [CI](ci.md#api-key)); pull requests from forks fall
back to the demo key. A compiled APK can still be inspected like any client
binary, so the secret protects the repository, not the installed artifact.
Only a server-side proxy can keep a key entirely off a client; this
client-only application accepts the trade-off for the mobile build.

Map timeouts, connection failures, unexpected responses, and malformed data
to usable application states. User-facing messages must not contain Dio
exceptions or stack traces. Retry requests data again through the provider.
