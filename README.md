
# Rails 8 API Image Processing with JWT Authentication

A Rails 8 API server that downloads and transforms images using [libvips](https://www.libvips.org/) with JWT-based authentication.

## Features

- Download a remote image and apply any libvips transformation in a single request.
- Export transformed images to common formats including `jpg`, `png`, `webp`, `avif`, and `heif`.
- JWT authentication via [devise-jwt](https://github.com/waiting-for-dev/devise-jwt).
- SSRF protection: blocks loopback, private, and link-local addresses.
- Response size limit (20 MB) to prevent memory exhaustion.
- Rate limiting on auth endpoints and `GET /image` via Rack::Attack.

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

With coverage report (output to `public/coverage/index.html`):

```bash
COVERAGE=1 bin/rails test
```

## Deployment

See [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md) for Kamal-based deployment instructions.

## License

This project is licensed under the MIT License.

