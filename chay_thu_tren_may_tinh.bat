@echo off
REM Chay thu dashboard tren may tinh (Chrome/Edge co Bluetooth). localhost duoc coi la an toan nen Web Bluetooth chay duoc.
cd /d "%~dp0"
start "" http://localhost:8000/
python -m http.server 8000 --bind 127.0.0.1
