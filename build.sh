#!/bin/zsh
# ============================================================
# SidecarSnap Build Script
# .app 번들 자동 생성 스크립트
# ============================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

APP_NAME="SidecarSnap"
APP_BUNDLE="$SCRIPT_DIR/$APP_NAME.app"
BINARY_NAME="SidecarSnap"
VERSION="1.0.0"

echo "🔨 SidecarSnap $VERSION 빌드 시작..."
echo ""

# ── 1. Release 빌드 ──────────────────────────────────────────
echo "[1/4] Swift 릴리즈 빌드..."
swift build -c release
echo "✅ 빌드 완료"
echo ""

# ── 2. .app 번들 구조 생성 ────────────────────────────────────
echo "[2/4] .app 번들 생성..."
rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

# 바이너리 복사
cp ".build/release/$BINARY_NAME" "$APP_BUNDLE/Contents/MacOS/"
chmod +x "$APP_BUNDLE/Contents/MacOS/$BINARY_NAME"

# Info.plist 복사
cp "Sources/Resources/Info.plist" "$APP_BUNDLE/Contents/"

# 앱 아이콘 복사
if [ -f "Assets/AppIcon.icns" ]; then
    cp "Assets/AppIcon.icns" "$APP_BUNDLE/Contents/Resources/"
    echo "  ✅ 앱 아이콘 포함됨"
else
    echo "  ⚠️  Assets/AppIcon.icns 없음 - 아이콘 없이 진행"
fi

echo "✅ .app 번들 생성 완료: $APP_BUNDLE"
echo ""

# ── 3. 실행 권한 확인 ─────────────────────────────────────────
echo "[3/4] 실행 권한 설정..."
xattr -cr "$APP_BUNDLE" 2>/dev/null || true
echo "✅ 완료"
echo ""

# ── 4. 번들 정보 출력 ─────────────────────────────────────────
echo "[4/4] 번들 정보:"
echo "  📦 경로: $APP_BUNDLE"
BUNDLE_SIZE=$(du -sh "$APP_BUNDLE" | cut -f1)
echo "  📏 크기: $BUNDLE_SIZE"
echo ""
echo "══════════════════════════════════════"
echo "  🎉 SidecarSnap.app 준비 완료!"
echo "══════════════════════════════════════"
echo ""
echo "실행 방법:"
echo "  open \"$APP_BUNDLE\""
echo ""
echo "⚠️  처음 실행 시:"
echo "  시스템 환경설정 > 개인정보 보호 및 보안 > 접근성에서"
echo "  SidecarSnap을 허용해주세요."
