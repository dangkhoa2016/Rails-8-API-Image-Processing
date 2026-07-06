# API Xử lý Ảnh Rails 8 với Xác thực JWT

[![Ruby 3.4.7](https://img.shields.io/badge/Ruby-3.4.7-red?style=flat&logo=ruby&logoColor=white)](https://www.ruby-lang.org/)
[![Rails 8.1.3](https://img.shields.io/badge/Rails-8.1.3-CC0000?logo=rubyonrails&logoColor=white)](https://rubyonrails.org/)
[![CircleCI](https://dl.circleci.com/status-badge/img/gh/dangkhoa2016/Rails-8-API-Image-Processing/tree/main.svg?style=svg)](https://dl.circleci.com/status-badge/redirect/gh/dangkhoa2016/Rails-8-API-Image-Processing/tree/main)
[![GitHub Actions](https://github.com/dangkhoa2016/Rails-8-API-Image-Processing/actions/workflows/ci.yml/badge.svg)](https://github.com/dangkhoa2016/Rails-8-API-Image-Processing/actions/workflows/ci.yml)
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
- Dọn dẹp danh sách chặn JWT qua job/task.
- Docker + Kamal deployment scaffolding với điểm cuối kiểm tra sức khỏe.
- Xuất ảnh đã biến đổi sang các định dạng phổ biến gồm `jpg`, `png`, `webp`, `avif` và `heif`.
- Xác thực JWT qua [devise-jwt](https://github.com/waiting-for-dev/devise-jwt).
- Bảo vệ SSRF: chặn địa chỉ loopback, private và link-local, bao gồm IPv6 `fe80::/10`.
- Ngắt tải xuống từ xa dạng stream (10 MB) để hủy nội dung vượt quá kích thước trước khi đệm toàn bộ tải trọng.
- Bộ nhớ đệm ảnh từ xa trong tiến trình cho các tải xuống thành công: TTL 5 phút, tối đa 64 mục mỗi tiến trình ứng dụng.
- Phản hồi ảnh thành công bao gồm header `X-Image-Width` và `X-Image-Height`.
- Giới hạn tốc độ trên các điểm cuối xác thực và `GET /image` qua Rack::Attack.
- Trang kiểm thử trình duyệt tích hợp sẵn bằng tiếng Anh và tiếng Việt trong `public/`.

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

2. Cài đặt các gói hệ thống.

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
- AVIF sẽ hiển thị bộ mã hóa như `aom`.
- HEIF/HEIC sẽ hiển thị bộ mã hóa như `x265`.

Nếu `heif-enc --list-encoders` chỉ hiển thị AVIF và không có bộ mã hóa HEIC/HEIF, `toFormat=heif` sẽ thất bại với lỗi tương tự `heifsave: Unsupported compression`.

## Quick Start xác thực local

Luồng này dành cho môi trường local sạch và tương ứng với các route được cover bởi auth integration tests.

1. Chạy ứng dụng bằng `bin/dev` và giữ nó hoạt động tại `http://localhost:3000` (trừ khi bạn đã override `PORT`).

2. Đăng ký người dùng mới trong terminal khác.

```bash
curl -sS -X POST http://localhost:3000/users \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "user@example.com",
      "username": "user1",
      "password": "password",
      "password_confirmation": "password"
    }
  }' | jq .
```

3. Lấy confirmation token từ database local.

```bash
bin/rails runner 'puts User.find_by!(email: "user@example.com").confirmation_token'
```

4. Xác nhận tài khoản.

```bash
curl -sS "http://localhost:3000/users/confirmation?confirmation_token=<token>" | jq .
```

5. Đăng nhập và lấy JWT từ header `Authorization` trong response.

```bash
TOKEN=$(curl -is -X POST http://localhost:3000/users/sign_in \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "user@example.com",
      "password": "password"
    }
  }' | sed -n 's/^authorization: Bearer //p' | tr -d '\r')
```

6. Gọi endpoint profile với JWT.

```bash
curl -sS http://localhost:3000/user/profile \
  -H "Authorization: Bearer ${TOKEN}" | jq .
```

7. Đăng xuất và thu hồi token.

```bash
curl -sS -X DELETE http://localhost:3000/users/sign_out \
  -H "Authorization: Bearer ${TOKEN}" | jq .
```

8. (Tùy chọn) Tham khảo thêm các request trong `manual/session.sh`, `manual/registration.sh`, `manual/password.sh`, và `manual/user.sh` cho các trường hợp token không hợp lệ, token hết hạn, reset mật khẩu, và ví dụ quản lý user/admin.

## Môi trường

Sao chép `.env.sample` thành `.env` cho môi trường local:

```bash
cp .env.sample .env
```

Các cấu hình đề xuất cho môi trường local:

```env
RAILS_ENV=development
RAILS_LOG_TO_STDOUT=true
PORT=4000
RAILS_MAX_THREADS=3
```

Nếu không thiết lập `PORT`, `bin/dev` sẽ chạy mặc định trên `3000`. File `.env.sample` hiện đặt sẵn `PORT=4000`, nên nếu bạn copy nguyên file này thì local sẽ chạy tại `http://localhost:4000`. Toàn bộ danh sách biến môi trường — bao gồm secret cho production, cấu hình Puma, mailer, admin seed, CORS, và JWT token cho manual scripts — được mô tả trong `.env.sample`.

Với browser client chạy khác origin, cấu hình CORS mặc định cho phép request từ `CORS_ALLOWED_ORIGINS` nhưng **không** expose response header `Authorization`. Nếu frontend cần đọc JWT từ response đăng nhập, hãy cập nhật `config/initializers/cors.rb` để expose header này một cách rõ ràng.

## Code Coverage

Bạn có thể tạo báo cáo coverage local với SimpleCov bằng cách chạy test kèm biến `COVERAGE=1`:

```bash
COVERAGE=1 bin/rails test
```

Khi bật `COVERAGE=1`, test suite sẽ chạy không dùng Rails parallel workers để báo cáo SimpleCov không bị sai lệch.

Báo cáo sẽ được ghi vào `public/coverage`. Khi Rails server đang chạy trong môi trường development, bạn có thể mở `http://localhost:3000/coverage` để xem report mới nhất. Endpoint này chỉ bật ở development và chỉ redirect tới báo cáo HTML tĩnh.

Về bên trong, ứng dụng redirect `/coverage` sang `/coverage/` trước khi static file server xử lý request. Dấu `/` ở cuối là cần thiết vì HTML do SimpleCov sinh ra tham chiếu asset theo dạng đường dẫn tương đối như `./assets/...`.

## Contract Route hiện tại

Các route dưới đây phản ánh `config/routes.rb` và implementation hiện tại của controller.

### Route xác thực

| Method    | Path                  | Mục đích                                           |
| --------- | --------------------- | -------------------------------------------------- |
| POST      | `/users`              | Đăng ký tài khoản mới                              |
| POST      | `/users/sign_in`      | Đăng nhập và nhận JWT trong header `Authorization` |
| DELETE    | `/users/sign_out`     | Đăng xuất và thu hồi token hiện tại                |
| GET       | `/users/confirmation` | Xác nhận email qua flow confirmable của Devise     |
| POST      | `/users/password`     | Gửi email đặt lại mật khẩu                         |
| PUT/PATCH | `/users/password`     | Đặt lại mật khẩu với token                         |
| PUT/PATCH | `/users`              | Cập nhật tài khoản đang đăng nhập                  |
| DELETE    | `/users`              | Xóa tài khoản đang đăng nhập                       |

### Route hồ sơ

| Method | Path            | Mục đích             |
| ------ | --------------- | -------------------- |
| GET    | `/user/profile` | Endpoint hồ sơ chính |
| GET    | `/user/me`      | Alias tương thích    |
| GET    | `/user/whoami`  | Alias tương thích    |

Cả ba route hồ sơ này cùng trỏ vào một action controller và trả về cùng một cấu trúc response.

### Route quản lý người dùng & admin

| Method | Path            | Mục đích                                    |
| ------ | --------------- | ------------------------------------------- |
| GET    | `/users`        | Lấy danh sách người dùng (chỉ admin)        |
| POST   | `/users/create` | Tạo người dùng (admin)                      |
| GET    | `/users/:id`    | Xem người dùng (admin hoặc chính mình)      |
| PUT    | `/users/:id`    | Cập nhật người dùng (admin hoặc chính mình) |
| DELETE | `/users/:id`    | Xóa người dùng (admin hoặc chính mình)      |

### Route tiện ích

| Method | Path    | Mục đích                                 |
| ------ | ------- | ---------------------------------------- |
| GET    | `/`     | Endpoint chào mừng ở root                |
| GET    | `/home` | Alias của endpoint chào mừng             |
| GET    | `/up`   | Health check cho uptime monitor/balancer |

## Ghi chú về format request

Các endpoint của Devise yêu cầu payload được lồng dưới key `user`. Với endpoint đăng ký `POST /users`, trường `username` là bắt buộc.

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

Request self-service cập nhật tài khoản trên `PUT /users` hoặc `PATCH /users` bắt buộc phải có `current_password`. Các request admin-managed trên `PUT /users/:id` đi qua `UsersController` nên không yêu cầu `current_password`.

Endpoint profile cũng có 2 kiểu lỗi xác thực khác nhau:

- Token thiếu, hết hạn, hoặc đã bị thu hồi: `422` với `user: null` và `token_info`
- Token bị lỗi format/malformed: `422` với `{ "error": "Invalid token" }`

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

### 2. Xác nhận email

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

JWT được trả về trong header `Authorization`.

### 4. Xem hồ sơ

```bash
curl http://localhost:3000/user/profile \
  -H "Authorization: Bearer <jwt_token>"
```

`/user/me` và `/user/whoami` là các alias tương thích cho cùng một response.

### 5. Đăng xuất

```bash
curl -X DELETE http://localhost:3000/users/sign_out \
  -H "Authorization: Bearer <jwt_token>"
```

## Tài liệu tham khảo thủ công

Các file dưới đây chứa ví dụ curl để copy/paste, dùng làm tài liệu tham khảo:

* [manual/registration.sh](./manual/registration.sh)
* [manual/session.sh](./manual/session.sh)
* [manual/password.sh](./manual/password.sh)
* [manual/user.sh](./manual/user.sh)

## Tài liệu chuyên sâu

Thư mục `docs/` chứa các ghi chú chi tiết hơn về implementation và vận hành của hệ thống xác thực hiện tại:

* [docs/ACCESS_CONTROL.vi.md](./docs/ACCESS_CONTROL.vi.md) - Quy tắc phân quyền cho guest, self-service, và admin
* [docs/JWT_LIFECYCLE.vi.md](./docs/JWT_LIFECYCLE.vi.md) - Vòng đời JWT, metadata ở endpoint profile, thu hồi, và dọn dẹp denylist
* [docs/RATE_LIMITING.vi.md](./docs/RATE_LIMITING.vi.md) - Các ngưỡng Rack::Attack hiện tại, response khi throttle, và lưu ý sau reverse proxy
* [docs/DEPLOYMENT.vi.md](./docs/DEPLOYMENT.vi.md) - Triển khai với Kamal, Docker, biến môi trường, health check, và persistence của SQLite

## Kế hoạch cải tiến

Các tài liệu theo dõi cải tiến hiện có nằm trong thư mục `manual/`:

* [manual/PROJECT_IMPROVEMENT_REPORT.md](./manual/PROJECT_IMPROVEMENT_REPORT.md)
* [manual/IMPLEMENTATION_TRACKER.md](./manual/IMPLEMENTATION_TRACKER.md)

## Dự án liên quan

Dự án này có một phiên bản Node.js triển khai các khái niệm xác thực tương tự (JWT, kiểm soát truy cập theo vai trò, thu hồi token) trên một stack khác:

- **[dangkhoa2016/Nodejs-API-Authentication](https://github.com/dangkhoa2016/Nodejs-API-Authentication)** — Một REST API sẵn sàng cho production dành cho xác thực và quản lý người dùng, được xây dựng bằng **Hono**, **Sequelize**, **bcryptjs**, **JWT**, và **SQLite** (dev) / **Postgres** (prod).

## License

Dự án này được cấp phép theo MIT License.

Xem file [LICENSE](LICENSE) để biết thêm chi tiết.
