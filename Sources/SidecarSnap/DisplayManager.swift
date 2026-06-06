import Cocoa
import CoreGraphics

// MARK: - Sidecar Display Info
struct SidecarDisplayInfo {
    let displayID: CGDirectDisplayID
    let bounds: CGRect
    let name: String
}

// MARK: - DisplayManager
/// Sidecar(iPad) 디스플레이를 감지하고 배치를 변경하는 매니저
final class DisplayManager {

    static let shared = DisplayManager()

    private(set) var sidecarDisplay: SidecarDisplayInfo?
    private(set) var mainDisplay: SidecarDisplayInfo?
    private(set) var currentArrangement: DisplaySide = .right

    enum DisplaySide {
        case left, right
    }

    private init() {}

    // MARK: - Detection

    /// 현재 연결된 디스플레이를 갱신하고 Sidecar 디스플레이를 탐지합니다.
    @discardableResult
    func refreshDisplays() -> Bool {
        let maxDisplays: UInt32 = 16
        var displayIDs = [CGDirectDisplayID](repeating: 0, count: Int(maxDisplays))
        var displayCount: UInt32 = 0

        let result = CGGetOnlineDisplayList(maxDisplays, &displayIDs, &displayCount)
        guard result == .success, displayCount > 0 else {
            sidecarDisplay = nil
            mainDisplay = nil
            return false
        }

        var foundMain: SidecarDisplayInfo?
        var foundSidecar: SidecarDisplayInfo?

        for i in 0..<Int(displayCount) {
            let displayID = displayIDs[i]
            let bounds = CGDisplayBounds(displayID)
            let name = getDisplayName(for: displayID)

            let info = SidecarDisplayInfo(displayID: displayID, bounds: bounds, name: name)

            if CGDisplayIsMain(displayID) != 0 {
                foundMain = info
            } else if isSidecarDisplay(displayID: displayID, name: name) {
                foundSidecar = info
            }
        }

        mainDisplay = foundMain
        sidecarDisplay = foundSidecar

        // 현재 배치 상태 업데이트
        if let main = foundMain, let sidecar = foundSidecar {
            currentArrangement = sidecar.bounds.origin.x < main.bounds.origin.x ? .left : .right
        }

        return foundSidecar != nil
    }

    /// Sidecar가 연결되어 있는지 확인합니다.
    var isSidecarConnected: Bool {
        return sidecarDisplay != nil
    }

    // MARK: - Arrangement

    /// Sidecar 디스플레이를 지정한 방향으로 배치합니다.
    func arrangeSidecar(to side: DisplaySide) {
        guard let sidecar = sidecarDisplay,
              let main = mainDisplay else {
            return
        }

        // 이미 같은 배치면 스킵
        if currentArrangement == side { return }

        var configRef: CGDisplayConfigRef?
        let status = CGBeginDisplayConfiguration(&configRef)
        guard status == .success, let config = configRef else {
            NSLog("[SidecarSnap] CGBeginDisplayConfiguration 실패: \(status.rawValue)")
            return
        }

        let mainBounds = CGDisplayBounds(main.displayID)
        let sidecarBounds = CGDisplayBounds(sidecar.displayID)

        let newX: Int32
        let newY: Int32 = Int32(mainBounds.origin.y)

        switch side {
        case .left:
            // Sidecar를 맥북 화면 왼쪽에 배치
            newX = Int32(mainBounds.origin.x) - Int32(sidecarBounds.width)
        case .right:
            // Sidecar를 맥북 화면 오른쪽에 배치
            newX = Int32(mainBounds.origin.x) + Int32(mainBounds.width)
        }

        CGConfigureDisplayOrigin(config, sidecar.displayID, newX, newY)

        let completeStatus = CGCompleteDisplayConfiguration(config, .forSession)
        if completeStatus == .success {
            currentArrangement = side
            let sideName = side == .left ? "왼쪽" : "오른쪽"
            NSLog("[SidecarSnap] Sidecar 배치 변경 완료: \(sideName)")
        } else {
            CGCancelDisplayConfiguration(config)
            NSLog("[SidecarSnap] CGCompleteDisplayConfiguration 실패: \(completeStatus.rawValue)")
        }
    }

    // MARK: - Private Helpers

    /// 디스플레이 이름을 가져옵니다.
    private func getDisplayName(for displayID: CGDirectDisplayID) -> String {
        // macOS 14+ (Sonoma)에서는 NSScreen으로 이름 가져오기
        if let screen = NSScreen.screens.first(where: {
            guard let id = $0.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID else { return false }
            return id == displayID
        }) {
            return screen.localizedName
        }
        return "Display \(displayID)"
    }

    /// Sidecar 디스플레이인지 판별합니다.
    /// macOS 최신 버전에서는 NSScreen.localizedName에 iPad 모델명이 직접 표시됩니다.
    private func isSidecarDisplay(displayID: CGDirectDisplayID, name: String) -> Bool {
        let nameLower = name.lowercased()

        // 이름 기반 판별 (macOS Monterey+ 에서 가장 신뢰할 수 있는 방법)
        // Sidecar 연결 시 NSScreen.localizedName에 "iPad", "iPad Air", "iPad Pro" 등이 포함됩니다.
        let sidecarKeywords = ["ipad", "sidecar"]
        for keyword in sidecarKeywords {
            if nameLower.contains(keyword) {
                return true
            }
        }

        return false
    }
}
