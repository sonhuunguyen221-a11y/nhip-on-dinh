# Hướng dẫn triển khai "Nhịp Ổn Định" (31/10/2026)

Thư mục này là MỘT trang web dùng được 3 cách: (A) mở thử trên máy tính, (B) trang web https trên điện thoại,
(C) cài thành app trên màn hình chính (PWA), tuỳ chọn (D) đóng gói file APK.
Cả 3 cách dùng CÙNG các file:

```
dashboard_ble/
  index.html              trang dashboard
  manifest.webmanifest    tên app, icon, màu (để cài thành app)
  sw.js                   cho phép mở app khi mất mạng
  icons/                  4 icon
  chay_thu_tren_may_tinh.bat
```

## Bước 0 — Nạp firmware v6
1. Arduino IDE → mở `C:\ECG_STRESS_ML\firmware_v6\ESP32S3_STRESS_PORT\ESP32S3_STRESS_PORT.ino`.
2. Tools: ESP32S3 Dev Module · Flash Size 4MB · Partition "Default 4MB with spiffs" · USB CDC On Boot Enabled.
   (Nếu lần trước bị lỗi partition: bật Erase All Flash = Enabled cho lần nạp này, nạp xong đặt lại Disabled.
   Erase sẽ xoá baseline cũ → calibration lại.)
3. Đóng Serial Monitor, Upload (nếu không nhận cổng: giữ BOOT, bấm RST, thả BOOT).
4. Mở Serial Monitor 115200, phải thấy: `[BLE] Advertising as "ECG-STRESS" ...` và dòng `[MODEL] ... rule=C(lien tiep)`.
   KHÔNG ghép đôi (pair) thiết bị trong Cài đặt Bluetooth của điện thoại — trang web tự kết nối.

## Cách A — Thử trên máy tính (không cần internet)
1. Laptop có Bluetooth, dùng Chrome hoặc Edge.
2. Bấm đúp `chay_thu_tren_may_tinh.bat` → trình duyệt mở http://localhost:8000.
3. Bấm "Kết nối thiết bị" → chọn ECG-STRESS. Đóng cửa sổ đen để tắt.

## Cách B — Đưa lên web (GitHub Pages, miễn phí, có https)
Web Bluetooth trên điện thoại BẮT BUỘC https → không mở file trực tiếp được.
1. Tạo tài khoản https://github.com (nếu chưa có).
2. Góc phải trên "+" → New repository. Tên: `nhip-on-dinh`. Chọn **Public**. Create repository.
3. Bấm link "uploading an existing file". Kéo thả **toàn bộ nội dung** thư mục `dashboard_ble`
   (index.html, manifest.webmanifest, sw.js và thư mục icons — kéo cả thư mục icons vào).
   Không cần đưa file .bat và .md. Bấm "Commit changes".
4. Settings → Pages → Source: "Deploy from a branch" → Branch: `main`, thư mục `/ (root)` → Save.
5. Chờ 1–2 phút, trang Pages hiện địa chỉ: `https://<tên-tài-khoản>.github.io/nhip-on-dinh/`.
6. Điện thoại Android: mở địa chỉ đó bằng **Chrome**. Bật Bluetooth và Vị trí. Bấm "Kết nối thiết bị",
   cho phép quyền "Thiết bị lân cận"/"Vị trí" khi Chrome hỏi, chọn ECG-STRESS.
   iPhone: Safari không có Web Bluetooth → cài app **Bluefy** (App Store) rồi mở địa chỉ trong Bluefy.

Trang công khai nhưng KHÔNG chứa dữ liệu ai: số đo chỉ đi từ thiết bị vào điện thoại đang mở trang.

## Cách C — Cài thành app trên màn hình chính
1. Mở địa chỉ ở Cách B bằng Chrome Android.
2. Menu ⋮ → "Cài đặt ứng dụng" / "Thêm vào màn hình chính" → Cài đặt.
3. Có icon "Nhịp Ổn Định" như app thường: mở toàn màn hình, không thanh địa chỉ, mở được cả khi
   không có mạng (Bluetooth không cần internet). Kết nối thiết bị như Cách B.
Cập nhật: sửa file → upload lại lên GitHub (ghi đè). Lần mở app kế tiếp có mạng sẽ tự lấy bản mới.
Nếu sửa icon hoặc manifest: đổi `nhip-on-dinh-v1` trong sw.js thành v2.

## Cách D (tuỳ chọn) — File APK để cài như app trên CH Play
1. Làm xong Cách B. Vào https://www.pwabuilder.com, dán địa chỉ GitHub Pages → Start.
2. Package for stores → Android → Generate → tải về file zip có APK (bản thử) và hướng dẫn ký.
3. Chép APK vào điện thoại, cho phép "cài ứng dụng không rõ nguồn" để cài.
APK này chạy trang web bằng Chrome bên trong (Trusted Web Activity) nên Bluetooth vẫn hoạt động.
KHÔNG dùng các công cụ "web → app" kiểu WebView thường (vd App Inventor WebViewer): Android WebView không có Web Bluetooth.

## Kiểm tra sau khi triển khai
- Serial: `[BLE] Phone connected.` khi bấm kết nối; ngắt kết nối thì `[BLE] Phone disconnected.` và tự quảng cáo lại.
- So `[HEALTH] ecg_missed` khi đang kết nối với khi không kết nối (và với v5). Tăng rõ → báo lại.
- Trên trang: mục "Gói dữ liệu gần nhất từ thiết bị" phải hiện dòng `L1,...,*` mỗi 15 giây.

## Lỗi thường gặp
| Hiện tượng | Cách xử lý |
|---|---|
| "Trình duyệt này không có Web Bluetooth" | Dùng Chrome Android/Chrome-Edge máy tính; iPhone dùng Bluefy |
| "Trang này không được phép dùng Bluetooth ở đây" | Đang mở trong Claude hoặc qua http → mở bản GitHub Pages (https) |
| Danh sách chọn thiết bị trống | Thiết bị chưa chạy v6, hoặc đang kết nối với điện thoại khác; bật Vị trí; tắt bật Bluetooth |
| Kết nối được nhưng không có số | Thiết bị đang chờ calibration → bấm BOOT; số đầu tiên sau ~15 giây |
| GitHub Pages báo 404 | Chờ thêm 2 phút; kiểm tra index.html nằm ngay gốc repo (không nằm trong thư mục con) |
