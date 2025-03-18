
# Rails v8 API Image Processing with JWT Authentication

This is a simple Rails v8 API server that process image using JSON Web Tokens (JWT) for authentication. The server is built using the famous `lipvips` library and [Rails-8-API-Authentication](https://github.com/dangkhoa2016/Rails-8-API-Authentication).

## Features

- **Process Image:**
  - Apply any `lipvips` image processing operation to an image.

## Technologies Used

- **ruby-vips**: Ruby extension for the libvips image processing library ([link](https://github.com/libvips/ruby-vips)).
- **Faraday**: Simple, but flexible HTTP client library, with support for multiple backend ([link](https://github.com/lostisland/faraday)).
- **Color Conversion**: A ruby gem to perform color conversions ([link](https://github.com/devrieda/color_conversion)).
- **Rails-8-API-Authentication**: A simple Rails v8 API server with JWT authentication ([link](https://github.com/dangkhoa2016/Rails-8-API-Authentication)).

## Installation

1. Clone the repository:
    ```bash
    git clone <repository-url>
    cd <repository-folder>
    ```

2. Install dependencies:
    ```bash
    bundle install
    ```

3. Set up the SQLite database:
    - The application will automatically create a database file (`development.sqlite`) in the project root directory when the server starts. You can configure your database connection settings in the `config/database.yml` file if needed.

4. Create a `.env` file at the root of your project for environment variables:
    ```env
    RAILS_LOG_TO_STDOUT=true
	RAILS_ENV=development
	PORT=4000
	RAILS_MAX_THREADS=1
    ```

## API Endpoints

You must include the JWT token in the `Authorization` header for all requests. The token is generated when you log in to the server.

### 1. **POST /image**
- Process an image using `Vips::Image` and return the processed image.
- **Body**:
    ```json
    {
      "url": "https://example.com/image.jpg",
      "format": "png",
      "background": "#ff0000",
      "resize": {
        "width": 300,
        "height": 300,
      },
    }
    ```
- **Response**:
    ```image
    <processed_image>
    ```

### 2. **GET /image**
- Process an image using `Vips::Image` and return the processed image.
- **Body**:
    ```
    {
    }
    ```
  **Query**:
    ```
    "url=https://example.com/image.jpg&format=png&background=#ff0000&resize[width]=300&resize[height]=300"
    ```
- **Response**:
    ```image
    <processed_image>
    ```

## Example Usage

1. Register a user:
    ```bash
    curl -X POST http://localhost:4000/users/register -H "Content-Type: application/json" -d '{"email": "user@example.com", "password": "password123", "username": "user123"}'
    ```

2. Log in to get the JWT token:
    ```bash
    curl -X POST http://localhost:4000/users/login -H "Content-Type: application/json" -d '{"username": "user123", "password": "password123"}'
    ```

3. Process an image:
    ```bash
    curl -X GET http://localhost:4000/image?url=https://[....].png&toFormat=jpg&resize%5Bwidth%5D=300' -H "Authorization: Bearer <jwt_token>"
    ```

for more information, please check the [image.sh](./manual/image.sh) file.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
