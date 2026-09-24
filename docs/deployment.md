# Web deployment

The repository includes a [Dockerfile](../Dockerfile) and
[Nginx configuration](../nginx.conf) for serving the Flutter Web build. The
Docker image uses Flutter 3.35.6, generates required code, and builds the app
before Nginx serves the generated files.

## Live environment

The current deployment is available at
[thecatsapp.kobrax.dev](https://thecatsapp.kobrax.dev). Run the final-host
checks below after deployment changes.

## Build locally

```bash
flutter build web --release --dart-define-from-file=.env
```

The Docker build uses `.env.example`; the local `.env` is excluded from its
build context. The app must use only a public/demo API key because a value
compiled into Web output is visible to its users.

## Routing

Nginx falls back to `index.html` for application paths. That keeps GoRouter
detail links working when users refresh a page or open a breed URL directly.
Verify this behavior on the final host, not only through `flutter run`.

## Remote images on Web

The Cat API image host does not provide the CORS headers Flutter's default
network image path needs. The app therefore prefers an HTML `<img>` element on
Web. This allows browser loading and caching without repeated blocked-request
errors, but it has consequences:

- Flutter screenshot and `RepaintBoundary` APIs do not capture those images.
- Flutter color, opacity, and filter effects do not apply to the platform view.
- Browser image progress can be less detailed than Flutter byte-progress events.

Loading and unavailable artwork keeps the image frame intentional while an
image cannot yet be displayed. Once a photo is ready, the loading artwork is
removed rather than remaining behind a contained image.

## Cache behavior

Flutter Web can register a service worker that caches compiled assets. After a
deployment, a browser with a prior visit may continue to serve an old
`main.dart.js`, which can resemble an application regression. Before debugging
a hosted build, reload with cache disabled or clear the site's stored data.

## Final-host checklist

- Build the Docker image and deploy it to the intended host.
- Open `/` and a direct breed detail URL, then refresh both.
- Check browser console output while the catalogue and a detail gallery load.
- Verify the splash hand-off, image states, and language menu on the host.
- Check touch gestures on a physical mobile device when that target is in scope.

The current local release verification does not replace these final-host checks.
