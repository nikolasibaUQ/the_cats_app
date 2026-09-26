# Design and product behavior

## Objective

The app lets users explore cat breeds in a clean, vivid interface built on the
Pragma brand palette. Follow approved visual references when they exist. Keep
layouts readable on Flutter Web and common mobile widths; use a sensible
maximum content width on large screens. Avoid visual noise; gradients, shadows,
and motion appear only where they reinforce the brand direction.

The visual tokens are deliberate, taken from the Pragma design system: vivid
purple (`#6429CD`) marks selected and primary actions; deep purple (`#330072`)
opens the navigation gradient; cool gray (`#F6F7FC`) is the scaffold; white
(`#FFFFFF`) raises cards; near-black (`#0C0C0D`) and gray (`#666669`) carry
text; and pale gray (`#E8E8ED`) supports neutral states. Fuchsia (`#DD52DD`)
tints playful accents such as the temperament pills, and amber (`#F8A53C`)
marks the few elements that deserve a flash of color: the breed code badge and
the splash glow. Do not introduce literal black, white, or seed-derived accent
colors where an equivalent `ColorScheme` token exists.

The catalog and compact-detail AppBars paint the brand gradient from deep
purple to vivid purple with white foreground content, giving navigation a
stable brand accent. Content remains gray and white, while a focused search
field uses the same purple outline.

The interface supports Spanish and English. It follows the device language by
default and offers an in-app selector for either language or the system setting.
All UI copy, including error states and accessibility labels, belongs in ARB
files. The API supplies breed content in its own language; do not imply that
the application translates that content.

## Main flow

```text
Splash → Breeds → Breed Detail
```

All controls that look interactive must work. Reuse the central theme and
extract widgets when doing so improves clarity or real reuse.

## Splash

The splash briefly introduces the app for 2.2 seconds on entry and then goes
to `/breeds`.
It must not become an extra browser-history stop during normal navigation.
A direct `/breeds/:id` visit opens detail through its loading state without
first showing splash. Its fixed duration is a visual transition only: it never
waits for, starts, or blocks an API request.

The splash artwork is the bundled `assets/images/splash_image.png`, a square
illustration that grows with the viewport up to a comfortable size and gives
up room before the title and subtitle do, so it stays proportional on any
resolution without overflowing short screens. A soft radial glow in the brand
purple and amber sits behind the artwork.

## Breeds

Show the breeds returned by the API. Provide distinct loading, data, API-empty,
and error states. A recoverable error offers retry. Provider state should
prevent new requests caused solely by widget rebuilds.

Full-screen loading and unavailable states use the matching bundled artwork.
Select the 3:4 or 4:3 variant from the available layout constraints. The bitmap
contains no copy: render the translated message through Flutter and expose the
same localized meaning as its semantic label.

Search filters the loaded list by breed name or API-provided origin, ignoring
case and surrounding spaces. One-character input keeps the unfiltered list and
shows a short hint. Queries with at least two characters apply after a 350 ms
debounce so the grid does not rebuild for every keystroke. Clearing the field
restores the list immediately. A query with no matches has its own empty state,
distinct from an empty API response. Selecting a card opens `/breeds/:id`.

The API list is loaded once, but the screen initially renders eight matching
breeds and reveals eight more through an explicit action. This limits the
initial scroll without hiding matches from local search or generating another
network request. The reveal control is a solid purple button with a downward
arrow, so the action stands out among the white cards.

Each card shows the breed name and its country of origin, as the approved
design shows. The same card is reused for the suggestions on detail, where
only the identifying information belongs. On pointer devices the card lifts
with a brand-tinted shadow and purple border while hovered.

The heading and search field remain fixed while the result area scrolls. This
keeps the active query visible and avoids making the user scroll to the top to
change it.

## Breed detail

Use the route ID to resolve the breed from the list, including after a browser
refresh or direct visit. Show loading, error with retry, and unavailable-ID
states as appropriate.

The photo area stays fixed while the information scrolls independently: above
the text on narrow layouts and beside it on wide layouts. Its controls float on
the photo — leaving the detail, the language selector, and the breed code — so
the photo itself stays unobstructed. Previous and next buttons change photos;
they stay visible and disable at the corresponding end of the gallery. Tapping
a photo or the expand control opens a full-screen viewer. A gallery error offers
its own retry and must not replace otherwise usable breed information.

On compact layouts, an AppBar carries the back action and language selector;
the photo holds only gallery controls and the amber breed code badge. Its
pager controls use purple surfaces with white icons; disabled controls use the
pale gray neutral. On desktop, a contextual toolbar above the two-column
layout holds the labeled back action on the left and the labeled language
selector on the right. Screen controls never float above the photo, leaving it
for gallery controls and the breed code only.

The area frames each photo with its own proportion, bounded between 3:4 and 3:2
and by the space the layout offers, so a landscape photo is not zoomed into a
narrow column and a portrait one is not cropped into a wide band. The change of
shape between photos is a smooth resize, not a jump.

The information column follows the approved order. On compact layouts, the
breed name moves to the AppBar and is not repeated below the photo:

- breed name;
- overview cards for origin, breed group, life span, weight, and height;
- description;
- history;
- characteristics of the bundled reference dataset as 1-to-5 dot rows;
- binary traits of that dataset as labeled yes/no rows;
- temperament words as fuchsia-tinted pills;
- suggested breeds, with a counter for those left out and desktop previous/next
  controls;
- the Wikipedia article.

Every fact is rendered once. The overview cards are the only place that shows
origin, life span, weight, and height: the header does not repeat them and the
photo area does not carry an origin label. The header's weight chip, the
origin-and-life-span summary line, and the closing "back to all breeds" button
were removed for the same reason: the photo controls already leave the detail,
and the suggestions row already offers the catalog.

The trait sections come from the bundled reference dataset (see
`docs/api.md`): a breed without an entry simply omits both sections. Each
rating renders as a row whose label reads five dots, filled up to the value;
each binary trait renders as a row that states the label plus an explicit
localized yes or no, so a false value stays visible instead of appearing
absent.

Overview cards use three columns only when each card remains at least 180 px
wide; otherwise they use two columns. Labels and values wrap rather than being
truncated, so Spanish copy and API values remain readable.

Weight and height follow the reading system of the active language. Omit a
section whose values the API does not supply instead of showing an empty one.
Ratings, alternative names, and article links are not part of the detail at
all: the free-plan response never supplies them, so the models and the UI
carry no code for them. The article action always opens the Wikipedia search
for the breed name.

Follow [API field guidance](api.md).

## Navigation and Web hosting

- `/` presents splash on normal entry, then replaces it with `/breeds`.
- `/breeds` presents the list.
- `/breeds/:id` presents detail; unknown IDs show an unavailable state.
- Opening detail pushes it on top of the catalog, so returning restores the
  catalog with its scroll position, search text, and state. Browser back and
  forward work with route history.
- A direct detail visit or a browser refresh has no previous route, so the in-app
  back action opens the catalog instead of failing.
- Selecting a suggested breed replaces the active detail in place. The URL
  updates for refreshes and sharing, but it does not add another detail to the
  navigation stack; returning goes back to the catalog.
- The counter for the remaining breeds opens the full catalog, unfiltered.
- On desktop, the suggestions row has previous/next buttons; touch users can
  still scroll it directly.
- Web hosting must serve the Flutter entry point for application routes so a
  direct visit or refresh does not return an Nginx 404.

## Images, errors, and responsiveness

Remote images need loading, missing-URL, and failed-request fallbacks. Photos
come in many proportions (the live breed list spans 0.63 to 1.93), so a photo
frames itself with its own shape inside a calm band instead of being scaled to
fill a fixed rectangle: measured on the live data, the fixed desktop rectangle
hid 42% of a photo on average and the photo-shaped frame keeps about 97% of it.
Catalog cards keep one uniform frame so the grid stays aligned. Do not leave an
otherwise usable page blank while one image loads or fails.

The Cat API serves its photos from `cdn2.thecatapi.com`, which does not send
`Access-Control-Allow-Origin`. Flutter Web reads image bytes with XHR, so the
browser blocks that request, logs one CORS error per photo, and only then falls
back to an HTML element. Measured in Chromium, `WebHtmlElementStrategy.fallback`
produced six blocked requests on the first catalog screen. `AppRemoteImage`
therefore sets `webHtmlElementStrategy: WebHtmlElementStrategy.prefer`: the
`<img>` element is used directly, the browser caches it, and no blocked request
is issued. The option is ignored on mobile and desktop, where bytes are always
fetched and `loadingBuilder` still applies.

`AppRemoteImage` replaces its loading artwork with the photo as soon as the
image is ready; a failed request or a missing URL replaces the frame with the
unavailable artwork. The artwork is never retained behind a successfully
loaded contained photo. Both states select their portrait or landscape variant
from the frame constraints and keep localized copy in Flutter. Because every
card, detail gallery, and full-screen viewer uses this widget, the states remain
consistent throughout the app.

Error text should be understandable without exposing HTTP or Dio details.
Keep content visible during refresh when practical. Use the shared
`Responsive` helper for bounded spacing, icons, and viewport measurements.
Use available widget constraints for structural decisions so a narrow browser
window behaves like a narrow mobile viewport. A section label and its secondary
counter share a line while they both fit and wrap onto a second line when they
do not, so neither one is truncated or clipped. The breed result area adjusts
its grid columns below a fixed search section; detail uses a fixed top gallery
on narrow widths and a side-by-side gallery with independently scrolling
information on wide widths.
Keep content widths readable instead of scaling everything to the screen.
