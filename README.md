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
- SSRF protection: blocks loopback, private, and link-local addresses, including IPv6 `fe80::/10`.
- Response size limit (10 MB) to prevent memory exhaustion.
- Rate limiting on sign-in, registration, and password-reset endpoints.
- JWT denylist cleanup via Active Job and Rake task.
- Docker + Kamal deployment scaffolding with a health check endpoint.
- Export transformed images to common formats including `jpg`, `png`, `webp`, `avif`, and `heif`.
- JWT authentication via [devise-jwt](https://github.com/waiting-for-dev/devise-jwt).

## Technologies

| Gem | Purpose |
|-----|---------|
| [ruby-vips](https://github.com/libvips/ruby-vips) | libvips image processing |
| [Faraday](https://github.com/lostisland/faraday) | HTTP client for image download |
| [devise](https://github.com/heartcombo/devise) + [devise-jwt](https://github.com/waiting-for-dev/devise-jwt) | Authentication |
| [rack-cors](https://github.com/cyu/rack-cors) | CORS headers |
| [rack-attack](https://github.com/rack/rack-attack) | Rate limiting |
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

All endpoints (except Devise routes) require a valid JWT in the `Authorization` header:

```
Authorization: Bearer <token>
```

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

## Image API

### GET /image

Pass the image URL and transform parameters as query string:

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

This project has a sibling Node.js implementation that covers similar authentication concepts (JWT, role-based access control, token revocation) on a different stack:

- **[dangkhoa2016/Nodejs-API-Authentication](https://github.com/dangkhoa2016/Nodejs-API-Authentication)** — A production-ready REST API for authentication and user management, built with **Hono**, **Sequelize**, **bcryptjs**, **JWT**, **SQLite** (dev), and **Postgres** (prod).

## License

This project is licensed under the MIT License.

See the [LICENSE](LICENSE) file for details.

