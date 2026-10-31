@echo off
echo ============================================================
echo   Catatance - Push APK with New Logo to Android Device
echo ============================================================
echo.
adb devices
echo.
echo Installing build\app\outputs\flutter-apk\app-debug.apk ...
adb install -r build\app\outputs\flutter-apk\app-debug.apk
if %ERRORLEVEL% EQU 0 (
    echo.
    echo [SUCCESS] Berhasil terpasang di HP Android!
    echo Membuka aplikasi Catatance di layar HP...
    adb shell monkey -p com.zemetia.pencatatan_keuangan -c android.intent.category.LAUNCHER 1
) else (
    echo.
    echo [INFO] Jika gagal, pastikan:
    echo 1. Kabel USB terhubung ke HP dan PC.
    echo 2. Debugging USB aktif di Opsi Pengembang (Developer Options).
    echo 3. Izinkan popup konfirmasi debugging di layar HP.
)
echo.
pause
