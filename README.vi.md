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

  Giới hạn an toàn kích thước có thể cấu hình qua env để bảo vệ máy chủ khỏi các
  yêu cầu render cực lớn:

  ```bash
  IMAGE_MAX_RESIZE_WIDTH=4096
  IMAGE_MAX_RESIZE_HEIGHT=4096
  IMAGE_MAX_RESIZE_SCALE=8
  ```

  Các yêu cầu vượt quá bất kỳ giới hạn nào sẽ trả về `422 Unprocessable Content`
  trước khi libvips bắt đầu resize tốn kém.

  Trình duyệt từ nguồn gốc khác cũng nên kiểm tra
  `CORS_ALLOWED_ORIGINS` và nếu cần đọc các header phản hồi như
  `Authorization`, `X-Image-Width` hay `X-Image-Height`, hãy mở rộng
  `config/initializers/cors.rb` với các header `expose:` tường minh.

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

## Xác thực

Các điểm cuối API được bảo vệ sử dụng header `Authorization` với Bearer JWT:

```
Authorization: Bearer <token>
```

Các điểm cuối công khai không yêu cầu JWT bao gồm `/`, `/home`, `/up`, các luồng đăng ký / đăng nhập / xác nhận / đặt lại mật khẩu của Devise và các file tĩnh trong `public/` như `favicon.ico`, `robots.txt`, `test-render.html` và `test-render.vi.html`.

### Đăng ký

```bash
curl -X POST http://localhost:4000/users \
  -H "Content-Type: application/json" \
  -d '{"user": {"email": "user@example.com", "password": "password", "password_confirmation": "password"}}'
```

Xác nhận email của bạn qua liên kết được gửi đến hộp thư, sau đó đăng nhập.

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

Các bí danh tương thích `GET /user/me` và `GET /user/whoami` hiện đang định tuyến đến
cùng action với `GET /user/profile`.

## API Ảnh

Cả `GET /image` và `POST /image` đều yêu cầu JWT hợp lệ. `GET /image` bị giới hạn
tốc độ bởi Rack::Attack; `POST /image` hiện được xác thực nhưng không bị giới hạn
bởi bộ giới hạn tốc độ cấp ứng dụng.

### GET /image

Truyền URL ảnh (bắt buộc dưới dạng `url`, `u` được chấp nhận như bí danh tương thích)
và các tham số biến đổi dưới dạng chuỗi truy vấn:

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

### Header phản hồi

Các phản hồi ảnh thành công bao gồm các header siêu dữ liệu sau:

| Header | Ý nghĩa |
|-----|---------|
| `X-Image-Width` | Chiều rộng kết xuất cuối cùng (pixel) |
| `X-Image-Height` | Chiều cao kết xuất cuối cùng (pixel) |

Các header này được trang kiểm thử sử dụng để hiển thị kích thước kết xuất cuối cùng
ngay cả khi trình duyệt không thể xem trước định dạng trả về trực tiếp.

### Quy tắc tải từ xa

- URL từ xa phải phân giải thành `http` hoặc `https` và không được trỏ đến địa chỉ loopback, private hoặc link-local.
- Phản hồi upstream phải là `2xx`, có `content-type` bắt đầu bằng `image/` và quá trình tải xuống sẽ bị hủy ngay khi nội dung stream vượt quá 10 MB.
- Lỗi trong tải xuống, xác thực hoặc xử lý biến đổi trả về `422 Unprocessable Content` với nội dung JSON lỗi.

### Bộ nhớ đệm tải xuống từ xa

Các tải xuống ảnh upstream thành công được lưu trong bộ nhớ đệm trong tiến trình theo
URL nguồn trong 5 phút, tối đa 64 mục mỗi tiến trình ứng dụng. Điều này giảm các yêu
cầu lặp lại trong quá trình kiểm thử và các biến đổi lặp trên cùng một nguồn.

Ghi chú:
- Bộ nhớ đệm bị xóa khi tiến trình ứng dụng khởi động lại.
- Bộ nhớ đệm không được chia sẻ giữa nhiều tiến trình Puma hoặc nhiều máy chủ.

### Giới hạn an toàn Resize

Để tránh các yêu cầu như `resize[width]=99999&resize[height]=99999` hoặc hệ số
tỷ lệ rất lớn, API xác thực đầu vào resize dựa trên các giới hạn
env sau:

| Env | Mặc định | Mục đích |
|-----|---------|---------|
| `IMAGE_MAX_RESIZE_WIDTH` | `4096` | Chiều rộng yêu cầu tối đa được chấp nhận |
| `IMAGE_MAX_RESIZE_HEIGHT` | `4096` | Chiều cao yêu cầu tối đa được chấp nhận |
| `IMAGE_MAX_RESIZE_SCALE` | `8` | Hệ số tỷ lệ tối đa được chấp nhận |

Ví dụ thất bại:

```bash
curl "http://localhost:4000/image?url=https://example.com/photo.jpg&resize[width]=99999&resize[height]=99999" \
  -H "Authorization: Bearer <token>"
```

Phản hồi:

```json
{"error":"Resize exceeds allowed limits (max width: 4096, max height: 4096, max scale: 8)"}
```

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
- `avif` thường có thể xem trực tiếp trong các trình duyệt hiện đại.
- `heif` có thể được API tạo thành công nhưng vẫn không xem trước được trong trình duyệt được trang kiểm thử sử dụng. Trong trường hợp đó, hãy tải file về và kiểm tra bằng trình xem hỗ trợ HEIF/HEIC.
- `GET /image` bị giới hạn tốc độ. Nếu bạn đang kiểm tra nhiều biến thể nhanh chóng, hãy xem [docs/RATE_LIMITING.md](docs/RATE_LIMITING.md).

## Kiểm thử trình duyệt

Hai điểm vào kiểm thử tĩnh được phân phối cùng ứng dụng và phục vụ trực tiếp từ
`public/`:

- `http://localhost:4000/test-render.html` — Tiếng Anh mặc định
- `http://localhost:4000/test-render.vi.html` — Tiếng Việt

Hành vi hiện tại:
- Sử dụng Vue 3 CDN, không cần bước build frontend.
- Các kịch bản được nhóm; mỗi nhóm có nút chạy riêng để tránh kích hoạt tất cả yêu cầu cùng lúc.
- Mỗi thẻ hiển thị các tham số có thể chỉnh sửa và cho thấy URL yêu cầu chính xác đang được gửi.
- Các định dạng không xem trước được như một số phản hồi HEIF được hiển thị dưới dạng kết xuất thành công với trạng thái cảnh báo thay vì lỗi cứng.

Truy cập cùng nguồn gốc được khuyến nghị. Nếu bạn mở trang kiểm thử từ nguồn gốc
khác, trình duyệt sẽ không thể đọc `Authorization` hoặc các header kích thước ảnh
trừ khi CORS được cấu hình để hiển thị chúng.

## Chạy kiểm thử

```bash
bin/rails test
```

Với báo cáo độ phủ:

```bash
COVERAGE=1 bin/rails test
```

Khi `COVERAGE=1` được đặt, bộ kiểm thử chạy không có worker song song Rails để báo cáo SimpleCov giữ được độ chính xác.

Báo cáo được ghi vào `public/coverage`. Khi máy chủ Rails đang chạy ở môi trường development, mở `http://localhost:4000/coverage` để xem báo cáo mới nhất. Điểm cuối chỉ dành cho development này chuyển hướng đến báo cáo HTML tĩnh.

Nội bộ, ứng dụng chuyển hướng `/coverage` đến `/coverage/` trước khi máy chủ file tĩnh xử lý yêu cầu. Dấu gạch chéo ở cuối rất quan trọng vì SimpleCov HTML được tạo tham chiếu đến tài sản với đường dẫn tương đối như `./assets/...`.

## Hợp đồng tuyến đường hiện tại

Hợp đồng tuyến đường dưới đây phản ánh `config/routes.rb` và triển khai controller hiện tại.

### Tuyến đường xác thực

| Phương thức | Đường dẫn | Mục đích |
| --- | --- | --- |
| POST | `/users` | Đăng ký tài khoản mới |
| POST | `/users/sign_in` | Đăng nhập và nhận JWT trong header phản hồi `Authorization` |
| DELETE | `/users/sign_out` | Đăng xuất và thu hồi token hiện tại |
| GET | `/users/confirmation` | Xác nhận email qua luồng confirmable của Devise |
| POST | `/users/password` | Gửi hướng dẫn đặt lại mật khẩu |
| PUT/PATCH | `/users/password` | Đặt lại mật khẩu bằng token |
| PUT/PATCH | `/users` | Cập nhật tài khoản đã đăng nhập hiện tại |
| DELETE | `/users` | Xóa tài khoản đã đăng nhập hiện tại |

### Tuyến đường hồ sơ

| Phương thức | Đường dẫn | Mục đích |
| --- | --- | --- |
| GET | `/user/profile` | Điểm cuối hồ sơ chính |
| GET | `/user/me` | Bí danh tương thích |
| GET | `/user/whoami` | Bí danh tương thích |

Cả ba tuyến đường hồ sơ đều truy cập cùng một action controller và trả về cùng một cấu trúc tải trọng.

### Tuyến đường quản trị và quản lý người dùng

| Phương thức | Đường dẫn | Mục đích |
| --- | --- | --- |
| GET | `/users` | Danh sách người dùng, chỉ admin |
| POST | `/users/create` | Tạo người dùng với tư cách admin |
| GET | `/users/:id` | Xem người dùng; admin hoặc chính người đó |
| PUT | `/users/:id` | Cập nhật người dùng; admin hoặc chính người đó |
| DELETE | `/users/:id` | Xóa người dùng; admin hoặc chính người đó |

### Tuyến đường tiện ích

| Phương thức | Đường dẫn | Mục đích |
| --- | --- | --- |
| GET | `/` | Điểm cuối chào mừng gốc |
| GET | `/home` | Bí danh chào mừng |
| GET | `/up` | Kiểm tra sức khỏe cho uptime/load balancers |

## Ghi chú định dạng yêu cầu

Các điểm cuối Devise mong đợi tải trọng lồng dưới khóa `user`.

Ví dụ yêu cầu đăng ký:

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

Ví dụ yêu cầu đăng nhập:

```json
{
  "user": {
    "email": "user@example.com",
    "password": "password"
  }
}
```

Cập nhật tài khoản tự phục vụ trên `PUT /users` hoặc `PATCH /users` phải bao gồm `current_password`. Cập nhật do admin quản lý trên `PUT /users/:id` đi qua `UsersController` và không yêu cầu `current_password`.

Tra cứu hồ sơ cũng có hai chế độ thất bại không xác thực:

- Token thiếu, hết hạn hoặc bị thu hồi: `422` với `user: null` kèm `token_info`
- Token không hợp lệ: `422` với `{ "error": "Invalid token" }`

## Luồng ví dụ

### 1. Đăng ký

```bash
curl -X POST http://localhost:4000/users \
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

Sử dụng liên kết xác nhận do Devise tạo, ví dụ:

```bash
curl "http://localhost:4000/users/confirmation?confirmation_token=<token>"
```

### 3. Đăng nhập

```bash
curl -i -X POST http://localhost:4000/users/sign_in \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "user@example.com",
      "password": "password"
    }
  }'
```

JWT được trả về trong header phản hồi `Authorization`.

### 4. Đọc hồ sơ

```bash
curl http://localhost:4000/user/profile \
  -H "Authorization: Bearer <jwt_token>"
```

`/user/me` và `/user/whoami` là các bí danh tương thích cho cùng một phản hồi.

### 5. Đăng xuất

```bash
curl -X DELETE http://localhost:4000/users/sign_out \
  -H "Authorization: Bearer <jwt_token>"
```

## Tài liệu tham khảo thủ công

Các file dưới đây phản ánh triển khai hiện tại chính xác hơn các ví dụ README gốc, nhưng chúng bao gồm các khối đầu ra mẫu và nên được xem như ghi chú tham khảo thay vì script shell thực thi nguyên văn:

- [manual/registration.sh](./manual/registration.sh)
- [manual/session.sh](./manual/session.sh)
- [manual/password.sh](./manual/password.sh)
- [manual/user.sh](./manual/user.sh)

## Tài liệu bổ sung

Thư mục `docs/` chứa các ghi chú triển khai và vận hành sâu hơn cho ngăn xếp xác thực hiện tại:

- [docs/ACCESS_CONTROL.md](./docs/ACCESS_CONTROL.md) - Quy tắc ủy quyền cho luồng khách, tự phục vụ và admin
- [docs/JWT_LIFECYCLE.md](./docs/JWT_LIFECYCLE.md) - Phát hành JWT, siêu dữ liệu token hồ sơ, thu hồi và dọn dẹp
- [docs/RATE_LIMITING.md](./docs/RATE_LIMITING.md) - Ngưỡng Rack::Attack hiện tại, phản hồi lỗi và cân nhắc proxy
- [docs/DEPLOYMENT.md](./docs/DEPLOYMENT.md) - Kamal, Docker, biến môi trường, kiểm tra sức khỏe và bền vững SQLite

## Kế hoạch cải tiến

Các artifact cải tiến dự án được theo dõi trong:

- [manual/PROJECT_IMPROVEMENT_REPORT.md](./manual/PROJECT_IMPROVEMENT_REPORT.md)
- [manual/IMPLEMENTATION_TRACKER.md](./manual/IMPLEMENTATION_TRACKER.md)

## Tài liệu bổ sung

- [docs/ACCESS_CONTROL.md](docs/ACCESS_CONTROL.md)
- [docs/JWT_LIFECYCLE.md](docs/JWT_LIFECYCLE.md)
- [docs/RATE_LIMITING.md](docs/RATE_LIMITING.md)
- [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md)

## Dự án liên quan

Dự án này được phát triển dựa trên các dự án nền tảng và có các phiên bản song song trên các stack khác:

| Dự án | Mô tả |
|-------|-------|
| [Rails-8-API-Authentication](https://github.com/dangkhoa2016/Rails-8-API-Authentication) | Dự án nền tảng cung cấp lớp xác thực JWT cốt lõi (Devise + devise-jwt), kiểm soát truy cập, và cấu trúc Rails 8 API |
| [Nodejs-API-Authentication](https://github.com/dangkhoa2016/Nodejs-API-Authentication) | Dự án nền tảng tương tự trên stack Node.js (Express, JWT, SQLite) |
| [Nodejs-API-Image-Processing](https://github.com/dangkhoa2016/Nodejs-API-Image-Processing) | Phiên bản Node.js của dự án này, sử dụng thư viện **Sharp** để xử lý ảnh thay cho libvips |

## License

Dự án này được cấp phép theo MIT License.

Xem file [LICENSE](LICENSE) để biết thêm chi tiết.
