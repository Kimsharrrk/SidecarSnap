#!/bin/zsh
# SidecarSnap 빌드 & 실행 스크립트

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "🔨 SidecarSnap 빌드 중..."
swift build -c release 2>&1

if [ $? -ne 0 ]; then
    echo "❌ 빌드 실패"
    exit 1
fi

echo "✅ 빌드 완료"
echo "🚀 SidecarSnap 실행 중..."
echo ""
echo "📌 사용법:"
echo "  - 마우스를 맥북 화면 왼쪽 끝으로 이동하면 iPad가 왼쪽으로 배치됩니다"
echo "  - 마우스를 맥북 화면 오른쪽 끝으로 이동하면 iPad가 오른쪽으로 배치됩니다"
echo "  - 메뉴바 아이콘을 클릭하면 상태 확인 및 수동 배치가 가능합니다"
echo ""
echo "⚠️  처음 실행 시 '접근성 권한'을 허용해주세요."
echo ""

.build/release/SidecarSnap
