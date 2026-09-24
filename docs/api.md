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
Those fields are deliberately not mapped anywhere: the plan that actually
serves this app can never return them, so the DTO, the entity, and the UI
carry no code for them. Should the plan change or a richer key be adopted,
map each field at the Data boundary instead of inventing values.

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
`venom_codes`, `reference_image_id`, the 1–5 ratings, `alt_names`,
`wikipedia_url`, and the binary trait flags stay unmapped: the origin already
expresses the country in readable form, the remaining links duplicate what the
article button offers, and the free plan never returns the other fields, so
mapping them would add code for values nothing can ever render.

## Ratings and other paid fields

The public documentation still describes the 1–5 ratings (`adaptability`,
`affection_level`, `energy_level`, `grooming`, `health_issues`,
`intelligence`, `shedding_level`, `social_needs`, `vocalisation`, and the
friendly levels), the binary trait flags, `alt_names`, and `wikipedia_url`.
The free-plan response verified above returns none of them, so the app maps
and renders none of them. A rating the API never sends cannot be displayed
faithfully, and inventing one would misrepresent the breed.

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
repository, not the compiled Web app. Do not commit a private credential or
describe a client-side key as secret. A private key requires server-side
handling and access controls.

Map timeouts, connection failures, unexpected responses, and malformed data
to usable application states. User-facing messages must not contain Dio
exceptions or stack traces. Retry requests data again through the provider.
