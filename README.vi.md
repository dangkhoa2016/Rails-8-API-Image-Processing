# API Xử lý Ảnh Rails 8 với Xác thực JWT

[![Ruby 3.4.7](https://img.shields.io/badge/Ruby-3.4.7-red?style=flat&logo=ruby&logoColor=white)](https://www.ruby-lang.org/)
[![Rails 8.1.3](https://img.shields.io/badge/Rails-8.1.3-CC0000?logo=rubyonrails&logoColor=white)](https://rubyonrails.org/)
[![CircleCI](https://dl.circleci.com/status-badge/img/gh/dangkhoa2016/Rails-8-API-Image-Processing/tree/main.svg?style=svg)](https://dl.circleci.com/status-badge/redirect/gh/dangkhoa2016/Rails-8-API-Image-Processing/tree/main)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

> 🌐 Language / Ngôn ngữ: [English](README.md) | **Tiếng Việt**

Một máy chủ API Rails 8 tải xuống và chuyển đổi hình ảnh bằng [libvips](https://www.libvips.org/) kết hợp với xác thực dựa trên JWT.

## Tính năng

- Tải xuống hình ảnh từ xa và áp dụng bất kỳ chuyển đổi libvips nào trong một yêu cầu duy nhất.
- Xuất hình ảnh đã chuyển đổi sang các định dạng phổ biến bao gồm `jpg`, `png`, `webp`, `avif`, và `heif`.
- Xác thực JWT thông qua [devise-jwt](https://github.com/waiting-for-dev/devise-jwt).
- Bảo vệ chống SSRF: chặn các địa chỉ loopback, private (riêng tư) và link-local, bao gồm cả IPv6 `fe80::/10`.
- Ngắt tải xuống từ xa dạng luồng (20 MB) giúp hủy bỏ các phản hồi upstream quá lớn trước khi toàn bộ payload được lưu vào bộ nhớ đệm.
- Bộ nhớ đệm in-process (trong tiến trình) đối với các lượt tải xuống hình ảnh từ xa thành công: Thời gian sống (TTL) 5 phút, tối đa 64 mục cho mỗi tiến trình ứng dụng.
- Các phản hồi hình ảnh thành công bao gồm các header `X-Image-Width` và `X-Image-Height`.
- Giới hạn tốc độ (Rate limiting) trên các endpoint xác thực và `GET /image` thông qua Rack::Attack.
- Tích hợp sẵn các trang kiểm tra khói (smoke-test) trên trình duyệt bằng tiếng Anh và tiếng Việt trong thư mục `public/`.

## Công nghệ

| Gem | Mục đích |
|-----|---------|
| [ruby-vips](https://github.com/libvips/ruby-vips) | Xử lý ảnh libvips |
| [Faraday](https://github.com/lostisland/faraday) | HTTP client để tải ảnh |
| [devise](https://github.com/heartcombo/devise) + [devise-jwt](https://github.com/waiting-for-dev/devise-jwt) | Xác thực |
| [rack-cors](https://github.com/cyu/rack-cors) | Header CORS |
| [rack-attack](https://github.com/rack/rack-attack) | Giới hạn tốc độ |

## Cài đặt

1. Sao chép kho lưu trữ:
    ```bash
    git clone <repository-url>
    cd Rails-8-API-Image-Processing
  ```

2. Cài đặt các gói native.

   Môi trường phát triển cục bộ Ubuntu 24.04 / dựa trên Debian:
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

   Lưu ý:
   - `libvips` là bắt buộc cho mọi thao tác xử lý ảnh.
   - `libheif-plugin-aomenc` cho phép mã hóa AVIF.
   - `libheif-plugin-x265` cho phép mã hóa HEIF/HEIC.
   - Nếu bạn build bằng Dockerfile được cung cấp, image runtime đã cài đặt sẵn gói `x265` của Debian, vì vậy bạn chỉ cần build lại image.

3. Cài đặt các dependency của Ruby:
  ```bash
    bundle install
    ```

4. Sao chép tệp env mẫu và chỉnh sửa nếu cần:
    ```bash
    cp .env.sample .env
    ```

  Các giới hạn an toàn khi thay đổi kích thước có thể được cấu hình qua env để bảo vệ máy chủ khỏi các yêu cầu render quá lớn:

  ```bash
  IMAGE_MAX_RESIZE_WIDTH=4096
  IMAGE_MAX_RESIZE_HEIGHT=4096
  IMAGE_MAX_RESIZE_SCALE=8
  ```

  Các yêu cầu vượt quá bất kỳ giới hạn nào trong số này sẽ trả về `422 Unprocessable Content` trước khi libvips bắt đầu quá trình thay đổi kích thước tốn tài nguyên.

  Các client trình duyệt được phục vụ từ một nguồn gốc (origin) khác cũng nên xem lại `CORS_ALLOWED_ORIGINS` và nếu họ cần đọc các header phản hồi như `Authorization`, `X-Image-Width`, hoặc `X-Image-Height`, hãy mở rộng tệp `config/initializers/cors.rb` với các header `expose:` rõ ràng.

5. Thiết lập cơ sở dữ liệu và seed (khởi tạo) một người dùng admin:
    ```bash
    bin/rails db:create db:migrate db:seed
    ```

6. Khởi động máy chủ:
    ```bash
    bin/rails server -p 4000
    ```

Máy chủ sẽ lắng nghe tại `http://localhost:4000`.

### Xác minh Hỗ trợ Native Encoder (Bộ mã hóa)

Trước khi thử nghiệm `avif` hoặc `heif`, hãy xác minh rằng các native encoder đã sẵn sàng:

```bash
vips -l foreign | grep -i heif
heif-enc --list-encoders
```

Kết quả mong đợi:
- AVIF sẽ hiển thị một encoder như `aom`.
- HEIF/HEIC sẽ hiển thị một encoder như `x265`.

Nếu `heif-enc --list-encoders` chỉ hiển thị AVIF và không có encoder HEIC/HEIF nào, `toFormat=heif` sẽ thất bại với lỗi tương tự như `heifsave: Unsupported compression`.

## Xác thực

Các endpoint API được bảo vệ sử dụng header `Authorization` với một Bearer JWT:

```
Authorization: Bearer <token>
```

Các endpoint công khai không yêu cầu JWT bao gồm `/`, `/home`, `/up`, các luồng đăng ký / đăng nhập / xác nhận / đặt lại mật khẩu của Devise, và các tệp tĩnh trong `public/` như `favicon.ico`, `robots.txt`, `test-render.html`, và `test-render.vi.html`.

### Đăng ký

```bash
curl -X POST http://localhost:4000/users \
  -H "Content-Type: application/json" \
  -d '{"user": {"email": "user@example.com", "password": "password", "password_confirmation": "password"}}'
```

Xác nhận email của bạn bằng liên kết được gửi đến hộp thư đến, sau đó đăng nhập.

### Đăng nhập

```bash
curl -X POST http://localhost:4000/users/sign_in \
  -H "Content-Type: application/json" \
  -d '{"user": {"email": "user@example.com", "password": "password"}}' -i
```

JWT sẽ được trả về trong header phản hồi `Authorization`.

### Đăng xuất

```bash
curl -X DELETE http://localhost:4000/users/sign_out \
  -H "Authorization: Bearer <token>"
```

### Hồ sơ cá nhân (Profile)

```bash
curl http://localhost:4000/user/profile \
  -H "Authorization: Bearer <token>"
```

Các bí danh (alias) tương thích `GET /user/me` và `GET /user/whoami` hiện tại điều hướng đến cùng một action với `GET /user/profile`.

## API Hình ảnh

Cả `GET /image` và `POST /image` đều yêu cầu một JWT hợp lệ. `GET /image` bị giới hạn tốc độ bởi Rack::Attack; `POST /image` hiện được xác thực nhưng không bị điều tiết bởi trình giới hạn tốc độ cấp ứng dụng.

### GET /image

Truyền URL hình ảnh (bắt buộc là `url`, với `u` được chấp nhận như một bí danh tương thích) và các tham số chuyển đổi dưới dạng chuỗi truy vấn (query string):

```bash
curl "http://localhost:4000/image?url=[https://example.com/photo.jpg&resize](https://example.com/photo.jpg&resize)[width]=300&resize[height]=300&toFormat=webp" \
  -H "Authorization: Bearer <token>" \
  --output result.webp
```

### POST /image

Truyền các tham số dưới dạng JSON body:

```bash
curl -X POST http://localhost:4000/image \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{
    "url": "[https://example.com/photo.jpg](https://example.com/photo.jpg)",
    "toFormat": "webp",
    "resize": {"width": 300, "height": 300}
  }' --output result.webp
```

Tên các tham số chuyển đổi khớp với tên phương thức của libvips (ví dụ: `sharpen`, `resize`, `rotate`, `toFormat`). Xem thư mục `manual/` để biết thêm các ví dụ.

### Header Phản hồi

Các phản hồi hình ảnh thành công sẽ bao gồm các header metadata sau:

| Header | Ý nghĩa |
|-----|---------|
| `X-Image-Width` | Chiều rộng render cuối cùng tính bằng pixel |
| `X-Image-Height` | Chiều cao render cuối cùng tính bằng pixel |

Chúng được sử dụng bởi trang smoke-test để hiển thị kích thước render cuối cùng ngay cả khi trình duyệt không thể xem trước định dạng được trả về một cách trực tiếp.

### Quy tắc Lấy dữ liệu từ xa

- URL từ xa phải phân giải thành `http` hoặc `https` và không được trỏ đến các địa chỉ loopback, private hoặc link-local.
- Phản hồi upstream phải là `2xx`, có `content-type` bắt đầu bằng `image/`, và quá trình tải xuống sẽ bị hủy ngay khi thân luồng (streamed body) vượt quá 20 MB.
- Các lỗi trong quá trình tải xuống, xác thực, hoặc xử lý chuyển đổi sẽ trả về `422 Unprocessable Content` kèm theo một body lỗi dạng JSON.

### Bộ nhớ đệm Tải xuống từ xa

Các lượt tải hình ảnh upstream thành công được lưu vào bộ nhớ đệm in-process theo URL nguồn trong 5 phút, tối đa 64 mục cho mỗi tiến trình ứng dụng. Điều này giúp giảm thiểu các yêu cầu hotlink lặp đi lặp lại trong quá trình chạy thử nghiệm khói và các chuyển đổi lặp lại đối với cùng một nguồn.

Lưu ý:
- Bộ nhớ đệm sẽ bị xóa khi tiến trình ứng dụng khởi động lại.
- Bộ nhớ đệm không được chia sẻ giữa nhiều tiến trình Puma hoặc nhiều máy chủ.

### Giới hạn An toàn khi Thay đổi kích thước

Để tránh các yêu cầu như `resize[width]=99999&resize[height]=99999` hoặc các hệ số tỷ lệ (scale factor) quá lớn, API xác thực dữ liệu đầu vào của thao tác thay đổi kích thước dựa trên các giới hạn thiết lập qua env sau:

| Biến môi trường | Mặc định | Mục đích |
|-----|---------|---------|
| `IMAGE_MAX_RESIZE_WIDTH` | `4096` | Chiều rộng yêu cầu tối đa được chấp nhận |
| `IMAGE_MAX_RESIZE_HEIGHT` | `4096` | Chiều cao yêu cầu tối đa được chấp nhận |
| `IMAGE_MAX_RESIZE_SCALE` | `8` | Hệ số tỷ lệ tối đa được chấp nhận |

Ví dụ khi thất bại:

```bash
curl "http://localhost:4000/image?url=[https://example.com/photo.jpg&resize](https://example.com/photo.jpg&resize)[width]=99999&resize[height]=99999" \
  -H "Authorization: Bearer <token>"
```

Phản hồi:

```json
{"error":"Resize exceeds allowed limits (max width: 4096, max height: 4096, max scale: 8)"}
```

### Ví dụ AVIF / HEIF

AVIF:

```bash
curl "http://localhost:4000/image?url=[https://example.com/photo.jpg&toFormat=avif](https://example.com/photo.jpg&toFormat=avif)" \
  -H "Authorization: Bearer <token>" \
  --output result.avif
```

HEIF:

```bash
curl "http://localhost:4000/image?url=[https://example.com/photo.jpg&toFormat=heif](https://example.com/photo.jpg&toFormat=heif)" \
  -H "Authorization: Bearer <token>" \
  --output result.heif
```

Lưu ý:
- `avif` thường có thể được xem trước trực tiếp trên các trình duyệt hiện đại.
- `heif` có thể được API tạo ra thành công nhưng vẫn không thể xem trước trong trình duyệt được trang smoke-test sử dụng. Trong trường hợp đó, hãy tải tệp xuống và kiểm tra nó bằng một trình xem hỗ trợ HEIF/HEIC.
- `GET /image` bị giới hạn tốc độ. Nếu bạn đang kiểm tra nhiều biến thể một cách nhanh chóng, hãy xem [docs/RATE_LIMITING.md](docs/RATE_LIMITING.md).

## Kiểm tra Khói trên Trình duyệt

Hai entry point (điểm đầu vào) thử nghiệm khói tĩnh được cung cấp kèm theo ứng dụng và được phục vụ trực tiếp từ thư mục `public/`:

- `http://localhost:4000/test-render.html` — Mặc định tiếng Anh
- `http://localhost:4000/test-render.vi.html` — Phiên bản tiếng Việt

Hành vi hiện tại:
- Sử dụng Vue 3 qua CDN, vì vậy không cần bước build frontend.
- Các kịch bản (scenario) được nhóm lại; mỗi nhóm có nút chạy riêng để tránh kích hoạt tất cả các yêu cầu cùng một lúc.
- Mỗi thẻ (card) hiển thị các tham số có thể chỉnh sửa và cho thấy chính xác URL yêu cầu đang được gửi đi.
- Các định dạng không thể xem trước như một số phản hồi HEIF được hiển thị là render thành công kèm theo trạng thái cảnh báo thay vì báo lỗi hoàn toàn.

Khuyến khích truy cập cùng nguồn gốc (Same-origin). Nếu bạn mở trang kiểm tra khói từ một nguồn gốc khác, trình duyệt sẽ không thể đọc được header `Authorization` hoặc header kích thước hình ảnh trừ khi CORS được định cấu hình để phơi bày (expose) chúng.

## Chạy Test

```bash
bin/rails test
```

Kèm theo báo cáo coverage (được xuất ra `public/coverage/index.html`):

```bash
COVERAGE=1 bin/rails test
```

## Triển khai

Xem [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md) để biết hướng dẫn triển khai dựa trên Kamal.

## Tài liệu Bổ sung

- [docs/ACCESS_CONTROL.md](docs/ACCESS_CONTROL.md)
- [docs/JWT_LIFECYCLE.md](docs/JWT_LIFECYCLE.md)
- [docs/RATE_LIMITING.md](docs/RATE_LIMITING.md)
- [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md)

## Giấy phép

Dự án này được cấp phép theo Giấy phép MIT.
