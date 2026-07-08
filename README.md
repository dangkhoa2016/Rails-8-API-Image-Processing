# Rails 8 API Image Processing with JWT Authentication

[![Ruby 3.4.7](https://img.shields.io/badge/Ruby-3.4.7-red?style=flat&logo=ruby&logoColor=white)](https://www.ruby-lang.org/)
[![Rails 8.1.3](https://img.shields.io/badge/Rails-8.1.3-CC0000?logo=rubyonrails&logoColor=white)](https://rubyonrails.org/)
[![GitHub Actions](https://github.com/dangkhoa2016/Rails-8-API-Image-Processing/actions/workflows/ci.yml/badge.svg)](https://github.com/dangkhoa2016/Rails-8-API-Image-Processing/actions/workflows/ci.yml)
[![CircleCI](https://dl.circleci.com/status-badge/img/gh/dangkhoa2016/Rails-8-API-Image-Processing/tree/main.svg?style=svg)](https://dl.circleci.com/status-badge/redirect/gh/dangkhoa2016/Rails-8-API-Image-Processing/tree/main)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

> 🌐 Language / Ngôn ngữ: **English** | [Tiếng Việt](README.vi.md)

A Rails 8 API server that downloads and transforms images using [libvips](https://www.libvips.org/) with JWT-based authentication.

Built on top of [Rails 8 API Authentication](https://github.com/dangkhoa2016/Rails-8-API-Authentication), which provides the core authentication layer that this project extends with image processing capabilities.

## Features

- Download a remote image and apply any libvips transformation in a single request.
- JWT-based sign in and sign out with token revocation via denylist.
- Profile lookup with token metadata via `/user/profile` and compatibility aliases.
- Self-service account update and account deletion.
- Admin-only user listing, user creation, role updates, and user deletion.
- JWT denylist cleanup via Active Job and Rake task.
- Docker + Kamal deployment scaffolding with a health check endpoint.
- Export transformed images to common formats including `jpg`, `png`, `webp`, `avif`, and `heif`.
- JWT authentication via [devise-jwt](https://github.com/waiting-for-dev/devise-jwt).
- SSRF protection: blocks loopback, private, and link-local addresses, including IPv6 `fe80::/10`.
- Streaming remote download cutoff (10 MB) aborts oversized upstream bodies before the full payload is buffered.
- In-process remote image caching for successful downloads: 5-minute TTL, 64 entries max per app process.
- Successful image responses include `X-Image-Width` and `X-Image-Height` headers.
- Rate limiting on auth endpoints and `GET /image` via Rack::Attack.
- Built-in browser smoke-test pages in English and Vietnamese under `public/`.

## Technologies Used

| Gem | Purpose |
|-----|---------|
| [ruby-vips](https://github.com/libvips/ruby-vips) | libvips image processing |
| [Faraday](https://github.com/lostisland/faraday) | HTTP client for image download |
| [devise](https://github.com/heartcombo/devise) + [devise-jwt](https://github.com/waiting-for-dev/devise-jwt) | Authentication |
| [rack-cors](https://github.com/cyu/rack-cors) | CORS headers |
| [rack-attack](https://github.com/rack/rack-attack) | Rate limiting |
| [color_conversion](https://github.com/ianks/color_conversion) | Color conversion for image processing |
| [puma](https://github.com/puma/puma) | Web server |
| [solid_cache](https://github.com/rails/solid_cache) | Database-backed cache |
| [solid_queue](https://github.com/rails/solid_queue) | Database-backed job queue |
| [solid_cable](https://github.com/rails/solid_cable) | Database-backed Action Cable adapter |
| [kamal](https://github.com/basecamp/kamal) | Docker deployment |
| [thruster](https://github.com/basecamp/thruster) | HTTP asset caching/compression |
| [dotenv](https://github.com/bkeepers/dotenv) | Environment variable loading |
| Rails 8 + SQLite | Framework and database |

## Quick Start

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
- The upstream response must be `2xx`, have a `content-type` starting with `image/`, and the download is aborted as soon as the streamed body exceeds 10 MB.
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

With coverage report:

```bash
COVERAGE=1 bin/rails test
```

When `COVERAGE=1` is set, the test suite runs without Rails parallel workers so the SimpleCov report stays accurate.

The report is written to `public/coverage`. While the Rails server is running in development, open `http://localhost:3000/coverage` to view the latest generated report. This development-only endpoint redirects to the static HTML report.

Internally, the app redirects `/coverage` to `/coverage/` before the static file server handles the request. The trailing slash matters because the generated SimpleCov HTML references assets with relative paths such as `./assets/...`.

## Current Route Contract

The route contract below reflects `config/routes.rb` and the current controller implementation.

### Authentication Routes

| Method | Path | Purpose |
| --- | --- | --- |
| POST | `/users` | Register a new account |
| POST | `/users/sign_in` | Sign in and receive JWT in the `Authorization` response header |
| DELETE | `/users/sign_out` | Sign out and revoke the current token |
| GET | `/users/confirmation` | Confirm email via Devise confirmable flow |
| POST | `/users/password` | Send password reset instructions |
| PUT/PATCH | `/users/password` | Reset password with a token |
| PUT/PATCH | `/users` | Update the current signed-in account |
| DELETE | `/users` | Delete the current signed-in account |

### Profile Routes

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/user/profile` | Primary profile endpoint |
| GET | `/user/me` | Compatibility alias |
| GET | `/user/whoami` | Compatibility alias |

All three profile routes hit the same controller action and return the same payload shape.

### Admin and User Management Routes

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/users` | List users, admin only |
| POST | `/users/create` | Create a user as admin |
| GET | `/users/:id` | View a user; admin or self |
| PUT | `/users/:id` | Update a user; admin or self |
| DELETE | `/users/:id` | Delete a user; admin or self |

### Utility Routes

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/` | Root welcome endpoint |
| GET | `/home` | Welcome endpoint alias |
| GET | `/up` | Health check for uptime/load balancers |

## Request Format Notes

Devise endpoints expect payloads nested under the `user` key. For registration (`POST /users`), the `username` field is required.

Example sign-up request:

```json
{
  "user": {
    "email": "user@example.com",
    "username": "user1",
    "password": "password",
    "password_confirmation": "password"
  }
}
```

Example sign-in request:

```json
{
  "user": {
    "email": "user@example.com",
    "password": "password"
  }
}
```

Self-service account updates on `PUT /users` or `PATCH /users` must include `current_password`. Admin-managed updates on `PUT /users/:id` go through `UsersController` and do not require `current_password`.

Profile lookup also has two different unauthenticated failure modes:

- Missing, expired, or revoked token: `422` with `user: null` plus `token_info`
- Malformed token: `422` with `{ "error": "Invalid token" }`

## Example Flow

### 1. Register

```bash
curl -X POST http://localhost:3000/users \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "user@example.com",
      "username": "user1",
      "password": "password",
      "password_confirmation": "password"
    }
  }'
```

### 2. Confirm Email

Use the confirmation link generated by Devise, for example:

```bash
curl "http://localhost:3000/users/confirmation?confirmation_token=<token>"
```

### 3. Sign In

```bash
curl -i -X POST http://localhost:3000/users/sign_in \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "user@example.com",
      "password": "password"
    }
  }'
```

The JWT is returned in the `Authorization` response header.

### 4. Read Profile

```bash
curl http://localhost:3000/user/profile \
  -H "Authorization: Bearer <jwt_token>"
```

`/user/me` and `/user/whoami` are compatibility aliases for the same response.

### 5. Sign Out

```bash
curl -X DELETE http://localhost:3000/users/sign_out \
  -H "Authorization: Bearer <jwt_token>"
```

## Manual References

The files below currently reflect the implementation more accurately than the original README examples, but they include sample output blocks and should be treated as reference notes rather than shell scripts you execute verbatim:

- [manual/registration.sh](./manual/registration.sh)
- [manual/session.sh](./manual/session.sh)
- [manual/password.sh](./manual/password.sh)
- [manual/user.sh](./manual/user.sh)

## Additional Documentation

The `docs/` folder contains deeper implementation and operations notes for the current authentication stack:

- [docs/ACCESS_CONTROL.md](./docs/ACCESS_CONTROL.md) - Authorization rules for guest, self-service, and admin flows
- [docs/JWT_LIFECYCLE.md](./docs/JWT_LIFECYCLE.md) - JWT issuance, profile-token metadata, revocation, and cleanup
- [docs/RATE_LIMITING.md](./docs/RATE_LIMITING.md) - Current Rack::Attack thresholds, error responses, and proxy considerations
- [docs/DEPLOYMENT.md](./docs/DEPLOYMENT.md) - Kamal, Docker, environment variables, health checks, and SQLite persistence

## Improvement Planning

Project improvement artifacts are tracked in:

- [manual/PROJECT_IMPROVEMENT_REPORT.md](./manual/PROJECT_IMPROVEMENT_REPORT.md)
- [manual/IMPLEMENTATION_TRACKER.md](./manual/IMPLEMENTATION_TRACKER.md)

## Related Projects

This project is built on and has counterparts across different stacks:

| Project | Description |
|---------|-------------|
| [Rails-8-API-Authentication](https://github.com/dangkhoa2016/Rails-8-API-Authentication) | Base project providing the core JWT authentication layer (Devise + devise-jwt), access control, and Rails 8 API structure |
| [Nodejs-API-Authentication](https://github.com/dangkhoa2016/Nodejs-API-Authentication) | Parallel base project on the Node.js stack (Express, JWT, SQLite) |
| [Nodejs-API-Image-Processing](https://github.com/dangkhoa2016/Nodejs-API-Image-Processing) | Node.js counterpart of this project, using **Sharp** for image processing instead of libvips |

## License

This project is licensed under the MIT License.

See the [LICENSE](LICENSE) file for details.
