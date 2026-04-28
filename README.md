
# Rails 8 API Image Processing with JWT Authentication

A Rails 8 API server that downloads and transforms images using [libvips](https://www.libvips.org/) with JWT-based authentication.

## Features

- Download a remote image and apply any libvips transformation in a single request.
- Export transformed images to common formats including `jpg`, `png`, `webp`, `avif`, and `heif`.
- JWT authentication via [devise-jwt](https://github.com/waiting-for-dev/devise-jwt).
- SSRF protection: blocks loopback, private, and link-local addresses, including IPv6 `fe80::/10`.
- Streaming remote download cutoff (20 MB) aborts oversized upstream bodies before the full payload is buffered.
- In-process remote image caching for successful downloads: 5-minute TTL, 64 entries max per app process.
- Successful image responses include `X-Image-Width` and `X-Image-Height` headers.
- Rate limiting on auth endpoints and `GET /image` via Rack::Attack.
- Built-in browser smoke-test pages in English and Vietnamese under `public/`.

## Technologies

| Gem | Purpose |
|-----|---------|
| [ruby-vips](https://github.com/libvips/ruby-vips) | libvips image processing |
| [Faraday](https://github.com/lostisland/faraday) | HTTP client for image download |
| [devise](https://github.com/heartcombo/devise) + [devise-jwt](https://github.com/waiting-for-dev/devise-jwt) | Authentication |
| [rack-cors](https://github.com/cyu/rack-cors) | CORS headers |
| [rack-attack](https://github.com/rack/rack-attack) | Rate limiting |

## Installation

1. Clone the repository:
    ```bash
    git clone <repository-url>
    cd Rails-8-API-Image-Processing
  ```

2. Install native packages.

   Ubuntu 24.04 / Debian-based local development:
  ```bash
  sudo apt-get update
  sudo apt-get install --no-install-recommends -y \
    build-essential \
    pkg-config \
    libvips \
    libheif-examples \
    libheif-plugin-aomenc \
    libheif-plugin-x265 \
    sqlite3
  ```

   Notes:
   - `libvips` is required for all image processing.
   - `libheif-plugin-aomenc` enables AVIF encoding.
   - `libheif-plugin-x265` enables HEIF/HEIC encoding.
   - If you build with the provided Dockerfile, the runtime image already installs the Debian `x265` package, so you only need to rebuild the image.

3. Install Ruby dependencies:
  ```bash
    bundle install
    ```

4. Copy the sample env file and edit as needed:
    ```bash
    cp .env.sample .env
    ```

  Resize safety limits are configurable via env to protect the server from
  extremely large render requests:

  ```bash
  IMAGE_MAX_RESIZE_WIDTH=4096
  IMAGE_MAX_RESIZE_HEIGHT=4096
  IMAGE_MAX_RESIZE_SCALE=8
  ```

  Requests that exceed any of these limits return `422 Unprocessable Content`
  before libvips starts an expensive resize.

  Browser clients served from a different origin should also review
  `CORS_ALLOWED_ORIGINS` and, if they need to read response headers such as
  `Authorization`, `X-Image-Width`, or `X-Image-Height`, extend
  `config/initializers/cors.rb` with explicit `expose:` headers.

5. Set up the database and seed an admin user:
    ```bash
    bin/rails db:create db:migrate db:seed
    ```

6. Start the server:
    ```bash
    bin/rails server -p 4000
    ```

The server listens on `http://localhost:4000`.

### Verify Native Encoder Support

Before testing `avif` or `heif`, verify the native encoders are available:

```bash
vips -l foreign | grep -i heif
heif-enc --list-encoders
```

Expected result:
- AVIF should show an encoder such as `aom`.
- HEIF/HEIC should show an encoder such as `x265`.

If `heif-enc --list-encoders` shows AVIF only and no HEIC/HEIF encoder, `toFormat=heif` will fail with an error similar to `heifsave: Unsupported compression`.

## Authentication

Protected API endpoints use the `Authorization` header with a Bearer JWT:

```
Authorization: Bearer <token>
```

Public endpoints that do not require a JWT include `/`, `/home`, `/up`, the Devise registration / sign-in / confirmation / password-reset flows, and static files under `public/` such as `favicon.ico`, `robots.txt`, `test-render.html`, and `test-render.vi.html`.

### Register

```bash
curl -X POST http://localhost:4000/users \
  -H "Content-Type: application/json" \
  -d '{"user": {"email": "user@example.com", "password": "password", "password_confirmation": "password"}}'
```

Confirm your email using the link sent to your inbox, then sign in.

### Sign In

```bash
curl -X POST http://localhost:4000/users/sign_in \
  -H "Content-Type: application/json" \
  -d '{"user": {"email": "user@example.com", "password": "password"}}' -i
```

The JWT is returned in the `Authorization` response header.

### Sign Out

```bash
curl -X DELETE http://localhost:4000/users/sign_out \
  -H "Authorization: Bearer <token>"
```

### Profile

```bash
curl http://localhost:4000/user/profile \
  -H "Authorization: Bearer <token>"
```

Compatibility aliases `GET /user/me` and `GET /user/whoami` currently route to the
same action as `GET /user/profile`.

## Image API

Both `GET /image` and `POST /image` require a valid JWT. `GET /image` is rate
limited by Rack::Attack; `POST /image` is currently authenticated but not
throttled by the app-level rate limiter.

### GET /image

Pass the image URL (required as `url`, with `u` accepted as a compatibility
alias) and transform parameters as a query string:

```bash
curl "http://localhost:4000/image?url=https://example.com/photo.jpg&resize[width]=300&resize[height]=300&toFormat=webp" \
  -H "Authorization: Bearer <token>" \
  --output result.webp
```

### POST /image

Pass parameters as JSON body:

```bash
curl -X POST http://localhost:4000/image \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{
    "url": "https://example.com/photo.jpg",
    "toFormat": "webp",
    "resize": {"width": 300, "height": 300}
  }' --output result.webp
```

Transform parameter names match libvips method names (e.g. `sharpen`, `resize`, `rotate`, `toFormat`). See the `manual/` folder for more examples.

### Response Headers

Successful image responses include these metadata headers:

| Header | Meaning |
|-----|---------|
| `X-Image-Width` | Final rendered width in pixels |
| `X-Image-Height` | Final rendered height in pixels |

These are used by the smoke-test page to show final rendered dimensions even
when the browser cannot preview the returned format directly.

### Remote Fetch Rules

- The remote URL must resolve to `http` or `https` and must not point to loopback, private, or link-local addresses.
- The upstream response must be `2xx`, have a `content-type` starting with `image/`, and the download is aborted as soon as the streamed body exceeds 20 MB.
- Failures in download, validation, or transform processing return `422 Unprocessable Content` with a JSON error body.

### Remote Download Cache

Successful upstream image downloads are cached in-process by source URL for 5
minutes, up to 64 entries per app process. This reduces repeated hotlink
requests during smoke tests and repeated transforms against the same source.

Notes:
- The cache is cleared when the app process restarts.
- The cache is not shared across multiple Puma processes or multiple servers.

### Resize Safety Limits

To avoid requests such as `resize[width]=99999&resize[height]=99999` or very
large scale factors, the API validates resize input against these env-based
limits:

| Env | Default | Purpose |
|-----|---------|---------|
| `IMAGE_MAX_RESIZE_WIDTH` | `4096` | Maximum accepted requested width |
| `IMAGE_MAX_RESIZE_HEIGHT` | `4096` | Maximum accepted requested height |
| `IMAGE_MAX_RESIZE_SCALE` | `8` | Maximum accepted scale factor |

Example failure:

```bash
curl "http://localhost:4000/image?url=https://example.com/photo.jpg&resize[width]=99999&resize[height]=99999" \
  -H "Authorization: Bearer <token>"
```

Response:

```json
{"error":"Resize exceeds allowed limits (max width: 4096, max height: 4096, max scale: 8)"}
```

### AVIF / HEIF Examples

AVIF:

```bash
curl "http://localhost:4000/image?url=https://example.com/photo.jpg&toFormat=avif" \
  -H "Authorization: Bearer <token>" \
  --output result.avif
```

HEIF:

```bash
curl "http://localhost:4000/image?url=https://example.com/photo.jpg&toFormat=heif" \
  -H "Authorization: Bearer <token>" \
  --output result.heif
```

Notes:
- `avif` can usually be previewed directly in modern browsers.
- `heif` may be generated successfully by the API while still failing to preview in the browser used by the smoke-test page. In that case, download the file and inspect it with a viewer that supports HEIF/HEIC.
- `GET /image` is rate limited. If you are testing many variants quickly, see [docs/RATE_LIMITING.md](docs/RATE_LIMITING.md).

## Browser Smoke Test

Two static smoke-test entry points are shipped with the app and served directly
from `public/`:

- `http://localhost:4000/test-render.html` — English default
- `http://localhost:4000/test-render.vi.html` — Vietnamese variant

Current behavior:
- Uses Vue 3 CDN, so no frontend build step is required.
- Scenarios are grouped; each group has its own run button to avoid firing all requests at once.
- Each card exposes editable parameters and shows the exact request URL being sent.
- Non-previewable formats such as some HEIF responses are shown as successful renders with a warning state instead of a hard failure.

Same-origin access is recommended. If you open the smoke-test page from a
different origin, the browser will not be able to read `Authorization` or image
dimension headers unless CORS is configured to expose them.

## Running Tests

```bash
bin/rails test
```

With coverage report (output to `public/coverage/index.html`):

```bash
COVERAGE=1 bin/rails test
```

## Deployment

See [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md) for Kamal-based deployment instructions.

## Additional Docs

- [docs/ACCESS_CONTROL.md](docs/ACCESS_CONTROL.md)
- [docs/JWT_LIFECYCLE.md](docs/JWT_LIFECYCLE.md)
- [docs/RATE_LIMITING.md](docs/RATE_LIMITING.md)
- [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md)

## License

This project is licensed under the MIT License.

