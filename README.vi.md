# API Xử lý Ảnh Rails 8 với Xác thực JWT

[![Ruby 3.4.7](https://img.shields.io/badge/Ruby-3.4.7-red?style=flat&logo=ruby&logoColor=white)](https://www.ruby-lang.org/)
[![Rails 8.1.3](https://img.shields.io/badge/Rails-8.1.3-CC0000?logo=rubyonrails&logoColor=white)](https://rubyonrails.org/)
[![GitHub Actions](https://github.com/dangkhoa2016/Rails-8-API-Image-Processing/actions/workflows/ci.yml/badge.svg)](https://github.com/dangkhoa2016/Rails-8-API-Image-Processing/actions/workflows/ci.yml)
[![CircleCI](https://dl.circleci.com/status-badge/img/gh/dangkhoa2016/Rails-8-API-Image-Processing/tree/main.svg?style=svg)](https://dl.circleci.com/status-badge/redirect/gh/dangkhoa2016/Rails-8-API-Image-Processing/tree/main)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

> 🌐 Language / Ngôn ngữ: [English](README.md) | **Tiếng Việt**

Máy chủ API Rails 8 tải xuống và biến đổi ảnh bằng [libvips](https://www.libvips.org/) với xác thực dựa trên JWT.

Được xây dựng trên nền tảng [Rails 8 API Authentication](https://github.com/dangkhoa2016/Rails-8-API-Authentication), dự án cung cấp lớp xác thực cốt lõi mà dự án này mở rộng thêm khả năng xử lý ảnh.

## Tính năng

- Tải ảnh từ xa và áp dụng bất kỳ phép biến đổi libvips nào trong một yêu cầu duy nhất.
- Đăng nhập/đăng xuất dựa trên JWT với thu hồi token qua danh sách chặn.
- Tra cứu hồ sơ kèm thông tin token qua `/user/profile` và các bí danh tương thích.
- Cập nhật và xóa tài khoản tự phục vụ.
- Danh sách người dùng, tạo người dùng, cập nhật vai trò và xóa người dùng chỉ dành cho quản trị viên.
- Bảo vệ SSRF: chặn địa chỉ loopback, private và link-local, bao gồm IPv6 `fe80::/10`.
- Giới hạn kích thước phản hồi (10 MB) để ngăn cạn kiệt bộ nhớ.
- Giới hạn tốc độ trên các điểm cuối đăng nhập, đăng ký và đặt lại mật khẩu.
- Dọn dẹp danh sách chặn JWT qua Active Job và Rake task.
- Docker + Kamal deployment scaffolding với điểm cuối kiểm tra sức khỏe.
- Xuất ảnh đã biến đổi sang các định dạng phổ biến gồm `jpg`, `png`, `webp`, `avif` và `heif`.
- Xác thực JWT qua [devise-jwt](https://github.com/waiting-for-dev/devise-jwt).

## Công nghệ

| Gem | Mục đích |
|-----|---------|
| [ruby-vips](https://github.com/libvips/ruby-vips) | Xử lý ảnh libvips |
| [Faraday](https://github.com/lostisland/faraday) | HTTP client để tải ảnh |
| [devise](https://github.com/heartcombo/devise) + [devise-jwt](https://github.com/waiting-for-dev/devise-jwt) | Xác thực |
| [rack-cors](https://github.com/cyu/rack-cors) | Header CORS |
| [rack-attack](https://github.com/rack/rack-attack) | Giới hạn tốc độ |
| Rails 8 + SQLite | Framework và cơ sở dữ liệu |

## Bắt đầu nhanh

1. Clone kho lưu trữ:
    ```bash
    git clone <repository-url>
    cd Rails-8-API-Image-Processing
    ```

2. Cài đặt gói hệ thống native.

   Ubuntu 24.04 / Debian phát triển cục bộ:
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

   Ghi chú:
   - `libvips` bắt buộc cho mọi xử lý ảnh.
   - `libheif-plugin-aomenc` kích hoạt mã hóa AVIF.
   - `libheif-plugin-x265` kích hoạt mã hóa HEIF/HEIC.
   - Nếu bạn build với Dockerfile đi kèm, ảnh runtime đã cài gói `x265` của Debian nên chỉ cần rebuild image.

3. Cài đặt phụ thuộc Ruby:
  ```bash
    bundle install
    ```

4. Sao chép file env mẫu và chỉnh sửa nếu cần:
    ```bash
    cp .env.sample .env
    ```

5. Thiết lập cơ sở dữ liệu và tạo người dùng admin:
    ```bash
    bin/rails db:create db:migrate db:seed
    ```

6. Khởi động máy chủ:
    ```bash
    bin/rails server -p 4000
    ```

Máy chủ lắng nghe tại `http://localhost:4000`.

### Kiểm tra hỗ trợ bộ mã hóa gốc

Trước khi kiểm tra `avif` hoặc `heif`, hãy xác minh bộ mã hóa gốc có sẵn:

```bash
vips -l foreign | grep -i heif
heif-enc --list-encoders
```

Kết quả mong đợi:
- AVIF nên hiển thị bộ mã hóa như `aom`.
- HEIF/HEIC nên hiển thị bộ mã hóa như `x265`.

Nếu `heif-enc --list-encoders` chỉ hiển thị AVIF mà không có bộ mã hóa HEIC/HEIF, `toFormat=heif` sẽ thất bại với lỗi tương tự `heifsave: Unsupported compression`.

## Xác thực

Tất cả các điểm cuối (trừ route Devise) yêu cầu một JWT hợp lệ trong header `Authorization`:

```
Authorization: Bearer <token>
```

### Đăng ký

```bash
curl -X POST http://localhost:4000/users \
  -H "Content-Type: application/json" \
  -d '{"user": {"email": "user@example.com", "password": "password", "password_confirmation": "password"}}'
```

Xác nhận email của bạn bằng liên kết được gửi đến hộp thư, sau đó đăng nhập.

### Đăng nhập

```bash
curl -X POST http://localhost:4000/users/sign_in \
  -H "Content-Type: application/json" \
  -d '{"user": {"email": "user@example.com", "password": "password"}}' -i
```

JWT được trả về trong header phản hồi `Authorization`.

### Đăng xuất

```bash
curl -X DELETE http://localhost:4000/users/sign_out \
  -H "Authorization: Bearer <token>"
```

### Hồ sơ

```bash
curl http://localhost:4000/user/profile \
  -H "Authorization: Bearer <token>"
```

## API Ảnh

### GET /image

Truyền URL ảnh và các tham số biến đổi dưới dạng query string:

```bash
curl "http://localhost:4000/image?url=https://example.com/photo.jpg&resize[width]=300&resize[height]=300&toFormat=webp" \
  -H "Authorization: Bearer <token>" \
  --output result.webp
```

### POST /image

Truyền tham số dưới dạng JSON body:

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

Tên tham số biến đổi khớp với tên phương thức libvips (ví dụ: `sharpen`, `resize`, `rotate`, `toFormat`). Xem thư mục `manual/` để biết thêm ví dụ.

### Ví dụ AVIF / HEIF

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

Ghi chú:
- `avif` thường có thể xem trước trực tiếp trong các trình duyệt hiện đại.
- `heif` có thể được API sinh thành công nhưng vẫn thất bại khi xem trước trong trình duyệt dùng bởi trang smoke-test. Trong trường hợp đó, tải file xuống và kiểm tra bằng trình xem hỗ trợ HEIF/HEIC.
- `GET /image` bị giới hạn tốc độ. Nếu bạn kiểm tra nhiều biến thể nhanh, hãy xem [docs/RATE_LIMITING.md](docs/RATE_LIMITING.md).

## Chạy kiểm thử

```bash
bin/rails test
```

Với báo cáo độ phủ:

```bash
COVERAGE=1 bin/rails test
```

Khi `COVERAGE=1` được thiết lập, test suite chạy không dùng Rails parallel workers để báo cáo SimpleCov chính xác.

Báo cáo được ghi vào `public/coverage`. Trong khi Rails server đang chạy trong môi trường development, mở `http://localhost:3000/coverage` để xem báo cáo mới nhất được tạo. Điểm cuối chỉ dành cho development này redirect đến báo cáo HTML tĩnh.

Bên trong, ứng dụng redirect `/coverage` sang `/coverage/` trước khi static file server xử lý request. Dấu `/` ở cuối rất quan trọng vì HTML do SimpleCov sinh ra tham chiếu asset qua đường dẫn tương đối như `./assets/...`.

## Hợp đồng tuyến đường hiện tại

Hợp đồng tuyến đường bên dưới phản ánh `config/routes.rb` và implementation hiện tại của controller.

### Tuyến đường xác thực

| Method | Path | Mục đích |
| --- | --- | --- |
| POST | `/users` | Đăng ký tài khoản mới |
| POST | `/users/sign_in` | Đăng nhập và nhận JWT trong header phản hồi `Authorization` |
| DELETE | `/users/sign_out` | Đăng xuất và thu hồi token hiện tại |
| GET | `/users/confirmation` | Xác nhận email qua flow confirmable của Devise |
| POST | `/users/password` | Gửi hướng dẫn đặt lại mật khẩu |
| PUT/PATCH | `/users/password` | Đặt lại mật khẩu với token |
| PUT/PATCH | `/users` | Cập nhật tài khoản đang đăng nhập |
| DELETE | `/users` | Xóa tài khoản đang đăng nhập |

### Tuyến đường hồ sơ

| Method | Path | Mục đích |
| --- | --- | --- |
| GET | `/user/profile` | Điểm cuối hồ sơ chính |
| GET | `/user/me` | Bí danh tương thích |
| GET | `/user/whoami` | Bí danh tương thích |

Cả ba tuyến đường hồ sơ đều trỏ vào cùng một controller action và trả về cùng một cấu trúc payload.

### Tuyến đường quản trị và quản lý người dùng

| Method | Path | Mục đích |
| --- | --- | --- |
| GET | `/users` | Lấy danh sách người dùng, chỉ admin |
| POST | `/users/create` | Tạo người dùng với tư cách admin |
| GET | `/users/:id` | Xem người dùng; admin hoặc chính mình |
| PUT | `/users/:id` | Cập nhật người dùng; admin hoặc chính mình |
| DELETE | `/users/:id` | Xóa người dùng; admin hoặc chính mình |

### Tuyến đường tiện ích

| Method | Path | Mục đích |
| --- | --- | --- |
| GET | `/` | Điểm cuối chào mừng root |
| GET | `/home` | Bí danh điểm cuối chào mừng |
| GET | `/up` | Kiểm tra sức khỏe cho uptime/load balancers |

## Ghi chú định dạng yêu cầu

Các điểm cuối Devise yêu cầu payload được lồng dưới key `user`. Với đăng ký (`POST /users`), trường `username` là bắt buộc.

Ví dụ request đăng ký:

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

Ví dụ request đăng nhập:

```json
{
  "user": {
    "email": "user@example.com",
    "password": "password"
  }
}
```

Các cập nhật tài khoản tự phục vụ trên `PUT /users` hoặc `PATCH /users` phải bao gồm `current_password`. Các cập nhật do admin quản lý trên `PUT /users/:id` đi qua `UsersController` và không yêu cầu `current_password`.

Tra cứu hồ sơ cũng có hai chế độ lỗi không xác thực khác nhau:

- Token thiếu, hết hạn, hoặc đã bị thu hồi: `422` với `user: null` cộng thêm `token_info`
- Token định dạng sai (malformed): `422` với `{ "error": "Invalid token" }`

## Luồng ví dụ

### 1. Đăng ký

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

### 2. Xác nhận Email

Sử dụng liên kết xác nhận do Devise sinh ra, ví dụ:

```bash
curl "http://localhost:3000/users/confirmation?confirmation_token=<token>"
```

### 3. Đăng nhập

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

JWT được trả về trong header phản hồi `Authorization`.

### 4. Đọc Hồ sơ

```bash
curl http://localhost:3000/user/profile \
  -H "Authorization: Bearer <jwt_token>"
```

`/user/me` và `/user/whoami` là các bí danh tương thích cho cùng một phản hồi.

### 5. Đăng xuất

```bash
curl -X DELETE http://localhost:3000/users/sign_out \
  -H "Authorization: Bearer <jwt_token>"
```

## Tài liệu tham khảo thủ công

Các file dưới đây hiện phản ánh implementation chính xác hơn các ví dụ README gốc, nhưng chúng bao gồm các khối output mẫu và nên được xem như ghi chú tham khảo thay vì script shell bạn thực thi nguyên văn:

- [manual/registration.sh](./manual/registration.sh)
- [manual/session.sh](./manual/session.sh)
- [manual/password.sh](./manual/password.sh)
- [manual/user.sh](./manual/user.sh)

## Tài liệu bổ sung

Thư mục `docs/` chứa các ghi chú implementation và vận hành sâu hơn cho stack xác thực hiện tại:

- [docs/ACCESS_CONTROL.md](./docs/ACCESS_CONTROL.md) - Quy tắc phân quyền cho guest, self-service và admin flows
- [docs/JWT_LIFECYCLE.md](./docs/JWT_LIFECYCLE.md) - Cấp phát JWT, profile-token metadata, thu hồi và dọn dẹp
- [docs/RATE_LIMITING.md](./docs/RATE_LIMITING.md) - Các ngưỡng Rack::Attack hiện tại, phản hồi lỗi và lưu ý proxy
- [docs/DEPLOYMENT.md](./docs/DEPLOYMENT.md) - Kamal, Docker, biến môi trường, health check và SQLite persistence

## Kế hoạch cải tiến

Các tài liệu cải tiến dự án được theo dõi trong:

- [manual/PROJECT_IMPROVEMENT_REPORT.md](./manual/PROJECT_IMPROVEMENT_REPORT.md)
- [manual/IMPLEMENTATION_TRACKER.md](./manual/IMPLEMENTATION_TRACKER.md)

## Dự án liên quan

Dự án này có một bản triển khai Node.js anh em bao phủ các khái niệm xác thực tương tự (JWT, kiểm soát truy cập theo vai trò, thu hồi token) trên một stack khác:

- **[dangkhoa2016/Nodejs-API-Authentication](https://github.com/dangkhoa2016/Nodejs-API-Authentication)** — Một REST API sẵn sàng cho production dành cho xác thực và quản lý người dùng, được xây dựng bằng **Hono**, **Sequelize**, **bcryptjs**, **JWT**, **SQLite** (dev) và **Postgres** (prod).

## License

Dự án này được cấp phép theo MIT License.

Xem file [LICENSE](LICENSE) để biết thêm chi tiết.

