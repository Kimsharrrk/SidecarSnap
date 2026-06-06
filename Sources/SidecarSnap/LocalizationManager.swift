import Foundation

// MARK: - Supported Languages
enum AppLanguage: String, CaseIterable {
    case english = "en"
    case korean = "ko"
    case japanese = "ja"

    var displayName: String {
        switch self {
        case .english:  return "English"
        case .korean:   return "한국어"
        case .japanese: return "日本語"
        }
    }
}

// MARK: - LocalizationManager
final class LocalizationManager {
    static let shared = LocalizationManager()
    private let languageKey = "AppLanguage"

    var currentLanguage: AppLanguage {
        get {
            if let saved = UserDefaults.standard.string(forKey: languageKey),
               let lang = AppLanguage(rawValue: saved) {
                return lang
            }
            // 시스템 언어 자동 감지는 삭제하고 기본값을 무조건 영어로.
            return .english
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: languageKey)
        }
    }

    func str(_ key: LocalizedString) -> String {
        return key.value(for: currentLanguage)
    }

    private init() {}
}

// Convenience shorthand
func L(_ key: LocalizedString) -> String {
    return LocalizationManager.shared.str(key)
}

// MARK: - LocalizedString
enum LocalizedString {
    // App
    case appName
    case version

    // Status
    case sidecarConnected
    case sidecarDisconnected
    case arrangementLeft
    case arrangementRight
    case arrangementNone
    case detecting

    // Menu items
    case autoDetectOn
    case manualArrange
    case moveLeft
    case moveRight
    case settings
    case delay03
    case delay05
    case delay10
    case launchAtLogin
    case checkAccessibility
    case startGuide
    case hideIcon
    case hideIconJoke
    case quit
    case language

    // HUD
    case hudLeft
    case hudRight

    // Onboarding
    case onboardingTitle
    case onboardingSubtitle
    case step1Title
    case step1Desc
    case step2Title
    case step2Desc
    case step3Title
    case step3Desc
    case accessibilityGranted
    case accessibilityNeeded
    case grantAccessibility
    case startButton

    // Accessibility Alert
    case accessibilityAlertTitle
    case accessibilityAlertBody
    case openSettings
    case later
    case accessibilityOkTitle
    case accessibilityOkBody
    case ok

    func value(for language: AppLanguage) -> String {
        switch (self, language) {

        // ── App ────────────────────────────────────────────────
        case (.appName, _):     return "SidecarSnap"
        case (.version, _):     return "v1.0"

        // ── Status ─────────────────────────────────────────────
        case (.sidecarConnected, .english):  return "✅ Sidecar: Connected"
        case (.sidecarConnected, .korean):   return "✅ Sidecar: 연결됨"
        case (.sidecarConnected, .japanese): return "✅ Sidecar: 接続中"

        case (.sidecarDisconnected, .english):  return "⚫ Sidecar: Not Connected"
        case (.sidecarDisconnected, .korean):   return "⚫ Sidecar: 연결 안됨"
        case (.sidecarDisconnected, .japanese): return "⚫ Sidecar: 未接続"

        case (.arrangementLeft, .english):  return "📍 Position: Left ◀"
        case (.arrangementLeft, .korean):   return "📍 배치: 왼쪽 ◀"
        case (.arrangementLeft, .japanese): return "📍 位置: 左 ◀"

        case (.arrangementRight, .english):  return "📍 Position: Right ▶"
        case (.arrangementRight, .korean):   return "📍 배치: 오른쪽 ▶"
        case (.arrangementRight, .japanese): return "📍 位置: 右 ▶"

        case (.arrangementNone, .english):  return "📍 Position: —"
        case (.arrangementNone, .korean):   return "📍 배치: —"
        case (.arrangementNone, .japanese): return "📍 位置: —"

        case (.detecting, .english):  return "Detecting..."
        case (.detecting, .korean):   return "감지 중..."
        case (.detecting, .japanese): return "検出中..."

        // ── Menu ───────────────────────────────────────────────
        case (.autoDetectOn, .english):  return "Auto-Detect Enabled"
        case (.autoDetectOn, .korean):   return "자동 감지 활성화"
        case (.autoDetectOn, .japanese): return "自動検出 有効"

        case (.manualArrange, .english):  return "Manual Arrange"
        case (.manualArrange, .korean):   return "수동 배치"
        case (.manualArrange, .japanese): return "手動配置"

        case (.moveLeft, .english):  return "  ◀ Move iPad to Left"
        case (.moveLeft, .korean):   return "  ◀ iPad를 왼쪽으로"
        case (.moveLeft, .japanese): return "  ◀ iPadを左へ"

        case (.moveRight, .english):  return "  ▶ Move iPad to Right"
        case (.moveRight, .korean):   return "  ▶ iPad를 오른쪽으로"
        case (.moveRight, .japanese): return "  ▶ iPadを右へ"

        case (.settings, .english):  return "Settings"
        case (.settings, .korean):   return "설정"
        case (.settings, .japanese): return "設定"

        case (.delay03, .english):  return "  ⏱ Delay: 0.3s (Fast)"
        case (.delay03, .korean):   return "  ⏱ 딜레이: 0.3초 (빠름)"
        case (.delay03, .japanese): return "  ⏱ 遅延: 0.3秒 (速い)"

        case (.delay05, .english):  return "  ⏱ Delay: 0.5s (Default)"
        case (.delay05, .korean):   return "  ⏱ 딜레이: 0.5초 (기본)"
        case (.delay05, .japanese): return "  ⏱ 遅延: 0.5秒 (デフォルト)"

        case (.delay10, .english):  return "  ⏱ Delay: 1.0s (Slow)"
        case (.delay10, .korean):   return "  ⏱ 딜레이: 1.0초 (느림)"
        case (.delay10, .japanese): return "  ⏱ 遅延: 1.0秒 (遅い)"

        case (.launchAtLogin, .english):  return "  Launch at Login"
        case (.launchAtLogin, .korean):   return "  로그인 시 자동 시작"
        case (.launchAtLogin, .japanese): return "  ログイン時に起動"

        case (.checkAccessibility, .english):  return "  Check Accessibility..."
        case (.checkAccessibility, .korean):   return "  접근성 권한 확인..."
        case (.checkAccessibility, .japanese): return "  アクセシビリティ確認..."

        case (.startGuide, .english):  return "  Setup Guide"
        case (.startGuide, .korean):   return "  시작 가이드"
        case (.startGuide, .japanese): return "  セットアップガイド"

        case (.hideIcon, .english):  return "  Hide Menu Bar Icon"
        case (.hideIcon, .korean):   return "  상단 아이콘 숨기기"
        case (.hideIcon, .japanese): return "  メニューバーアイコンを非表示"

        case (.hideIconJoke, .english):  return "  (We recommend hiding it, it's pretty ugly!)"
        case (.hideIconJoke, .korean):   return "  (워낙 아이콘이 못생겨서... 가리는 거 추천드립니다!)"
        case (.hideIconJoke, .japanese): return "  (アイコンが不細工なので隠すことをお勧めします！)"

        case (.quit, .english):  return "Quit SidecarSnap"
        case (.quit, .korean):   return "SidecarSnap 종료"
        case (.quit, .japanese): return "SidecarSnapを終了"

        case (.language, .english):  return "Language / 言語 / 언어"
        case (.language, .korean):   return "Language / 언어 / 言語"
        case (.language, .japanese): return "Language / 言語 / 언어"

        // ── HUD ────────────────────────────────────────────────
        case (.hudLeft, .english):  return "iPad → Left"
        case (.hudLeft, .korean):   return "iPad → 왼쪽"
        case (.hudLeft, .japanese): return "iPad → 左"

        case (.hudRight, .english):  return "iPad → Right"
        case (.hudRight, .korean):   return "iPad → 오른쪽"
        case (.hudRight, .japanese): return "iPad → 右"

        // ── Onboarding ─────────────────────────────────────────
        case (.onboardingTitle, .english):  return "Welcome to SidecarSnap"
        case (.onboardingTitle, .korean):   return "SidecarSnap에 오신 것을 환영합니다"
        case (.onboardingTitle, .japanese): return "SidecarSnapへようこそ"

        case (.onboardingSubtitle, .english):
            return "Mouse reaches screen edge → iPad auto-arranges"
        case (.onboardingSubtitle, .korean):
            return "마우스가 화면 끝에 닿으면 iPad가 자동으로 배치됩니다"
        case (.onboardingSubtitle, .japanese):
            return "マウスが画面端に触れると、iPadが自動で配置されます"

        case (.step1Title, .english):  return "Connect Sidecar"
        case (.step1Title, .korean):   return "Sidecar 연결"
        case (.step1Title, .japanese): return "Sidecarを接続"

        case (.step1Desc, .english):
            return "Sign in with the same Apple ID on both devices,\nthen enable Sidecar from Control Center."
        case (.step1Desc, .korean):
            return "두 기기에서 동일한 Apple ID로 로그인 후\n제어 센터에서 Sidecar를 활성화하세요."
        case (.step1Desc, .japanese):
            return "両デバイスで同じApple IDでサインインし、\nコントロールセンターからSidecarを有効にします。"

        case (.step2Title, .english):  return "Grant Accessibility"
        case (.step2Title, .korean):   return "접근성 권한 허용"
        case (.step2Title, .japanese): return "アクセシビリティを許可"

        case (.step2Desc, .english):
            return "Required to detect global mouse movement.\nClick the button below to grant access."
        case (.step2Desc, .korean):
            return "전역 마우스 이동 감지를 위해 필요합니다.\n아래 버튼을 눌러 권한을 허용해주세요."
        case (.step2Desc, .japanese):
            return "グローバルマウス検出のために必要です。\n下のボタンをクリックして許可してください。"

        case (.step3Title, .english):  return "You're All Set!"
        case (.step3Title, .korean):   return "준비 완료!"
        case (.step3Title, .japanese): return "準備完了！"

        case (.step3Desc, .english):
            return "Push mouse to left/right edge for 0.5s\n→ iPad automatically snaps to that side."
        case (.step3Desc, .korean):
            return "마우스를 화면 왼쪽/오른쪽 끝으로 0.5초 유지\n→ iPad가 자동으로 그쪽으로 배치됩니다."
        case (.step3Desc, .japanese):
            return "マウスを左右の端に0.5秒押し付けると\n→ iPadが自動でその側に配置されます。"

        case (.accessibilityGranted, .english):  return "✅ Accessibility permission granted"
        case (.accessibilityGranted, .korean):   return "✅ 접근성 권한이 허용됐습니다"
        case (.accessibilityGranted, .japanese): return "✅ アクセシビリティが許可されました"

        case (.accessibilityNeeded, .english):  return "⚠️ Accessibility permission required"
        case (.accessibilityNeeded, .korean):   return "⚠️ 접근성 권한이 필요합니다"
        case (.accessibilityNeeded, .japanese): return "⚠️ アクセシビリティの許可が必要です"

        case (.grantAccessibility, .english):  return "Grant Accessibility Permission"
        case (.grantAccessibility, .korean):   return "접근성 권한 허용하기"
        case (.grantAccessibility, .japanese): return "アクセシビリティを許可する"

        case (.startButton, .english):  return "Get Started →"
        case (.startButton, .korean):   return "시작하기 →"
        case (.startButton, .japanese): return "始める →"

        // ── Accessibility Alert ─────────────────────────────────
        case (.accessibilityAlertTitle, .english):  return "Accessibility Permission Needed"
        case (.accessibilityAlertTitle, .korean):   return "접근성 권한 필요"
        case (.accessibilityAlertTitle, .japanese): return "アクセシビリティの許可が必要"

        case (.accessibilityAlertBody, .english):
            return "SidecarSnap needs Accessibility access to detect mouse movement.\nGo to System Settings → Privacy & Security → Accessibility."
        case (.accessibilityAlertBody, .korean):
            return "마우스 이동 감지를 위해 시스템 환경설정 > 개인정보 보호 및 보안 > 접근성에서 앱을 허용해야 합니다."
        case (.accessibilityAlertBody, .japanese):
            return "マウス動作を検出するためにアクセシビリティの許可が必要です。\nシステム設定 → プライバシーとセキュリティ → アクセシビリティ"

        case (.openSettings, .english):  return "Open System Settings"
        case (.openSettings, .korean):   return "시스템 환경설정 열기"
        case (.openSettings, .japanese): return "システム設定を開く"

        case (.later, .english):  return "Later"
        case (.later, .korean):   return "나중에"
        case (.later, .japanese): return "後で"

        case (.accessibilityOkTitle, .english):  return "Accessibility Granted ✅"
        case (.accessibilityOkTitle, .korean):   return "접근성 권한 허용됨 ✅"
        case (.accessibilityOkTitle, .japanese): return "アクセシビリティが許可されました ✅"

        case (.accessibilityOkBody, .english):
            return "SidecarSnap is ready to detect mouse movement."
        case (.accessibilityOkBody, .korean):
            return "SidecarSnap이 마우스 이동을 감지할 준비가 됐습니다."
        case (.accessibilityOkBody, .japanese):
            return "SidecarSnapはマウス動作を検出する準備ができました。"

        case (.ok, .english):  return "OK"
        case (.ok, .korean):   return "확인"
        case (.ok, .japanese): return "OK"
        }
    }
}
