@echo off
REM Destiny Decoder APK Build Script
REM Quick script to build and prepare APK for testing

setlocal enabledelayedexpansion

echo.
echo ========================================
echo   Destiny Decoder APK Builder
echo ========================================
echo.

REM Check if we're in the right directory
if not exist "pubspec.yaml" (
    echo ERROR: pubspec.yaml not found!
    echo Please run this script from: mobile/destiny_decoder_app/
    exit /b 1
)

echo [1/5] Cleaning previous builds...
flutter clean
if !errorlevel! neq 0 (
    echo ERROR: Flutter clean failed
    exit /b 1
)

echo.
echo [2/5] Getting dependencies...
flutter pub get
if !errorlevel! neq 0 (
    echo ERROR: Flutter pub get failed
    exit /b 1
)

echo.
echo [3/5] Running analysis...
flutter analyze
if !errorlevel! neq 0 (
    echo WARNING: Analysis found issues (non-critical)
)

echo.
echo [4/5] Building APK...
echo.
echo Choose build type:
echo   1) Debug (larger, includes debug symbols)
echo   2) Release (smaller, optimized)
echo.
set /p BUILD_TYPE="Enter choice (1 or 2): "

if "%BUILD_TYPE%"=="1" (
    echo.
    echo Building DEBUG APK...
    flutter build apk --debug
    set APK_PATH=build\app\outputs\flutter-apk\app-debug.apk
) else if "%BUILD_TYPE%"=="2" (
    echo.
    echo Building RELEASE APK...
    flutter build apk --release
    set APK_PATH=build\app\outputs\flutter-apk\app-release-unsigned.apk
) else (
    echo ERROR: Invalid choice
    exit /b 1
)

if !errorlevel! neq 0 (
    echo ERROR: Build failed
    exit /b 1
)

echo.
echo [5/5] Build complete!
echo.
echo ========================================
echo   ✅ APK Ready for Testing
echo ========================================
echo.
echo Location: %APK_PATH%
echo.
echo File size:
for %%A in (!APK_PATH!) do echo   %%~zA bytes
echo.
echo Next steps:
echo   1. Transfer APK to Android device
echo   2. Enable "Install from unknown sources"
echo   3. Open APK and tap Install
echo   4. Run the app and test features
echo.
echo Installation command (if using adb):
echo   adb install "!APK_PATH!"
echo.
pause
