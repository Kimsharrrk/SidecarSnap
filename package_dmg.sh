#!/bin/bash

# 기존 DMG 파일 및 임시 폴더 삭제
rm -f SidecarSnap_v1.1.dmg
rm -rf /tmp/dmg_source
mkdir -p /tmp/dmg_source

# 최신 빌드된 앱 복사
cp -R SidecarSnap.app /tmp/dmg_source/

# DMG 생성 명령어
create-dmg \
  --volname "SidecarSnap" \
  --volicon "Assets/AppIcon.icns" \
  --background "Assets/dmg_background.png" \
  --window-pos 200 120 \
  --window-size 800 533 \
  --icon-size 150 \
  --icon "SidecarSnap.app" 200 250 \
  --hide-extension "SidecarSnap.app" \
  --app-drop-link 600 250 \
  "SidecarSnap_v1.1.dmg" \
  "/tmp/dmg_source/"

echo "✅ DMG 패키징 완료!"
