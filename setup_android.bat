@echo off
title HydroShield Android Setup

:: Step 1: Set Android SDK Path
set ANDROID_SDK_ROOT=C:\Android\Sdk
set ANDROID_HOME=C:\Android\Sdk

:: Step 2: Add to PATH
set PATH=%ANDROID_SDK_ROOT%\cmdline-tools\latest\bin;%ANDROID_SDK_ROOT%\platform-tools;%PATH%

:: Step 3: Accept Android Licenses
echo y | %ANDROID_SDK_ROOT%\cmdline-tools\latest\sdkmanager.bat --licles 2>nul

:: Step 4: Install Required SDK Packages
echo Installing Android SDK packages...
%CANDROID_SDK_ROOT%\cmdline-tools\latest\sdkmanager.bat "platforms;android-33" 2>nul
%CANDROID_SDK_ROOT%\cmdline-tools\latest\sdkmanager.bat "build-tools;33.0.2" 2>nul
%CANDROID_SDK_ROOT%\cmdline-tools\latest\sdkmanager.bat "platform-tools" 2>nul

:: Step 5: Verify adb
echo.
echo Checking ADB connection...
adb devices 2>nul

:: Step 5: Build HydroShield APK
echo.
echo Building HydroShield APK...
cd C:\hydroshield
flutter build apk --release 2>nul

echo.
echo ================================
echo HydroShield APK Build Complete
echo ================================
echo.
echo APK Location:
echo build\app\outputs\flutter-apk\app-release.apk
echo.
echo To install on Samsung Phone:
echo 1. Connect phone via USB with USB Debugging enabled
echo 2. Run: adb install build\app\outputs\flutter-apk\app-release.apk
echo 3. Or run: flutter install
echo.
pause