
# Rails 8 API Image Processing with JWT Authentication

A Rails 8 API server that downloads and transforms images using [libvips](https://www.libvips.org/) with JWT-based authentication.

## Features

- Download a remote image and apply any libvips transformation in a single request.
- JWT authentication via [devise-jwt](https://github.com/waiting-for-dev/devise-jwt).
- SSRF protection: blocks loopback, private, and link-local addresses.
- Response size limit (20 MB) to prevent memory exhaustion.
- Rate limiting on auth endpoints via Rack::Attack.

## Technologies

| Gem | Purpose |
|-----|---------|
| [ruby-vips](https://github.com/libvips/ruby-vips) | libvips image processing |
| [Faraday](https://github.com/lostisland/faraday) | HTTP client for image download |
| [devise](https://github.com/heartcombo/devise) + [devise-jwt](https://github.com/waiting-for-dev/devise-jwt) | Authentication |
| [rack-cors](https://github.com/cyu/rack-cors) | CORS headers |
| [rack-attack](https://github.com/rack/rack-attack) | Rate limiting |

## Installation

1. Clone the repository and install dependencies:
    ```bash
    git clone <repository-url>
    cd Rails-8-API-Image-Processing
    bundle install
    ```

2. Copy the sample env file and edit as needed:
    ```bash
    cp .env.sample .env
    ```

3. Set up the database and seed an admin user:
    ```bash
    bin/rails db:create db:migrate db:seed
    ```

4. Start the server:
    ```bash
    bin/rails server -p 4000
    ```

The server listens on `http://localhost:4000`.

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

