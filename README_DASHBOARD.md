# Dashboard "Nhịp Ổn Định" (31/10/2026, firmware v6)

Trang web trên điện thoại, nhận số liệu từ thiết bị qua Bluetooth LE, so sánh trạng thái HIỆN TẠI với trạng thái
ỔN ĐỊNH (baseline cá nhân đo lúc calibration 150 s).

## Hiển thị
- Trạng thái: bình thường / đang theo dõi sát / mức 1 / mức 2 / đang đo baseline / chờ tín hiệu ổn định.
- Điểm stress của bước 15 s (sau cổng HR) so với ngưỡng T_HI hiệu lực (tăng khi vừa bấm hủy).
- Bộ đếm luật C5: 5 ô × 15 s (đủ 75 s liên tiếp ≥ ngưỡng → mức 1).
- 3 kênh HR / RMSSD / nhịp thở: giá trị hiện tại, vùng ổn định (TB ± 1 SD, nhạt ± 2 SD), độ lệch theo SD,
  xu hướng 10 phút; ghi rõ baseline cá nhân (số cửa sổ) hay trung bình 22 người.
- Đóng góp từng đặc trưng vào điểm: w_i × z_i + b, điểm = sigmoid(tổng).
- Chất lượng tín hiệu: điện cực, ECG, cử động, chất lượng nhịp thở (%), số mẫu ECG bị lỡ.
- Chế độ mô phỏng (người giả định, model/ngưỡng/luật thật) — tự chạy khi mở trang.

## Dùng thật
1. Nạp firmware_v6 (Default 4MB partition vẫn đủ: 633 217 byte = 48%).
2. Đưa `index.html` lên một địa chỉ https (vd GitHub Pages: tạo repo, upload file, Settings → Pages).
   Web Bluetooth CHỈ chạy trên https (hoặc localhost) và trên Chrome Android / Edge / Chrome máy tính.
   iPhone: Safari không hỗ trợ, dùng app Bluefy. Bản xem trong Claude (artifact) chặn Bluetooth → chỉ xem mô phỏng.
3. Mở trang bằng Chrome trên Android, bật Bluetooth + Vị trí, bấm "Kết nối thiết bị", chọn ECG-STRESS.

## Giao thức (GATT)
- Service 6e7a0001-5c1f-4d8e-9b2a-3f0e5d7c1a01
- LIVE 6e7a0002-… READ+NOTIFY, mỗi 15 s, ~125 byte:
  `L1,epoch,uptime_s,state,hr,rmssd,resp,ecgOk,motionOk,respOk,respQ,leadsOff,signalValid,scoreValid,z0,z1,z2,p,evidence,level,sustain_s,need_s,thrHi,backoff,calPending,calStreak,calElapsed_s,calN0,calN1,calN2,motionStd,ecgMissed,baselineSeq,*`
- BASELINE 6e7a0003-… READ, ~192 byte:
  `B1,personal,src0,src1,src2,mu0,sd0,mu1,sd1,mu2,sd2,pmu0,psd0,pmu1,psd1,pmu2,psd2,w0,w1,w2,b,T_HI,T_LO,T_HI2,sustain_s,escalate_s,clear_s,step_s,useEma,hrGate,n0,n1,n2,floorFrac,*`
- "nan" = không hợp lệ ở bước đó. Thông báo bị cắt do MTU nhỏ → trang đọc lại bằng readValue().
- baselineSeq đổi → trang đọc lại BASELINE.

## Kiểm tra đã làm (31/10)
- Biên dịch arduino-cli, core esp32 3.3.12, ESP32-S3, NimBLE: 0 cảnh báo, 633 217 byte.
- Biên dịch với -DENABLE_BLE_DASHBOARD=0: 349 706 byte (≈ v5) → BLE tắt được hoàn toàn.
- Chuỗi định dạng C (32 trường LIVE, 33 trường BASELINE) khớp số đối số; bộ đọc JS đọc đúng gói mẫu,
  từ chối gói bị cắt và gói thừa trường (đối chứng âm).
- Trang: không lỗi script, không cuộn ngang ở 400 px, sáng/tối.

## CHƯA kiểm tra trên phần cứng
- Kết nối thật với điện thoại; [HEALTH] ecg_missed có tăng khi BLE bật không (so với v5); thời gian chạy pin.
- Firmware chỉ GỬI số liệu, không nhận lệnh: không đổi model, ngưỡng, baseline, luật cảnh báo.
