#!/usr/bin/env bash
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_NAME="Proxy5G"
APP_BUNDLE="/Applications/${APP_NAME}.app"

echo "🔨 Đang biên dịch ${APP_NAME} cho Apple Silicon..."
swiftc -O -target arm64-apple-macos12.0 "${DIR}/main.swift" -o "${DIR}/Proxy5G_bin"

echo "📦 Đang đóng gói ${APP_NAME}.app..."
killall "${APP_NAME}" 2>/dev/null || true
rm -rf "${APP_BUNDLE}"

mkdir -p "${APP_BUNDLE}/Contents/MacOS"
mkdir -p "${APP_BUNDLE}/Contents/Resources"

cp "${DIR}/Proxy5G_bin" "${APP_BUNDLE}/Contents/MacOS/${APP_NAME}"
chmod +x "${APP_BUNDLE}/Contents/MacOS/${APP_NAME}"
rm "${DIR}/Proxy5G_bin"

cp "${DIR}/Info.plist" "${APP_BUNDLE}/Contents/Info.plist"
cp "${DIR}/Resources/AppIcon.icns" "${APP_BUNDLE}/Contents/Resources/AppIcon.icns"
echo -n "APPL????" > "${APP_BUNDLE}/Contents/PkgInfo"

echo "🔏 Đang ký ad-hoc codesign..."
codesign --force --deep --sign - "${APP_BUNDLE}"

echo "🚀 Khởi chạy ${APP_NAME}..."
open "${APP_BUNDLE}"

echo "✅ Hoàn tất! ${APP_NAME} đã được cài đặt vào /Applications và đang chạy trên Menu Bar."
