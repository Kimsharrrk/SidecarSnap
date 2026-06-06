import Cocoa

// MARK: - MouseEdgeMonitor
/// 마우스 커서가 메인 디스플레이의 좌우 끝에 도달했을 때 감지하는 모니터
final class MouseEdgeMonitor {

    static let shared = MouseEdgeMonitor()

    /// 엣지 감지 임계값 (픽셀). 마우스가 이 범위 내에 있으면 트리거됩니다.
    var edgeThreshold: CGFloat = 2.0

    /// 배치 변경 전 마우스가 엣지에 머물러야 하는 시간 (초)
    var triggerDelay: TimeInterval = 0.5

    var isEnabled: Bool = false {
        didSet {
            if isEnabled {
                startMonitoring()
                EdgeIndicatorController.shared.setup()
            } else {
                stopMonitoring()
                EdgeIndicatorController.shared.teardown()
            }
        }
    }

    /// 엣지 감지 콜백
    var onEdgeDetected: ((DisplayManager.DisplaySide) -> Void)?

    private var globalMouseMonitor: Any?
    private var localMouseMonitor: Any?
    private var debounceTimer: Timer?
    private var pendingSide: DisplayManager.DisplaySide?
    private var timerStartDate: Date?

    private init() {}

    // MARK: - Start / Stop

    func startMonitoring() {
        guard globalMouseMonitor == nil else { return }

        globalMouseMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.mouseMoved, .leftMouseDragged]) { [weak self] _ in
            self?.handleMouseEvent()
        }

        localMouseMonitor = NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved, .leftMouseDragged]) { [weak self] event in
            self?.handleMouseEvent()
            return event
        }

        NSLog("[SidecarSnap] Mouse monitoring started")
    }

    func stopMonitoring() {
        if let monitor = globalMouseMonitor {
            NSEvent.removeMonitor(monitor)
            globalMouseMonitor = nil
        }
        if let monitor = localMouseMonitor {
            NSEvent.removeMonitor(monitor)
            localMouseMonitor = nil
        }
        debounceTimer?.invalidate()
        debounceTimer = nil
        pendingSide = nil
        timerStartDate = nil
        EdgeIndicatorController.shared.hideAll()

        NSLog("[SidecarSnap] Mouse monitoring stopped")
    }

    // MARK: - Edge Detection

    private func handleMouseEvent() {
        guard isEnabled else { return }

        guard DisplayManager.shared.isSidecarConnected else {
            resetAndHide(mouseLocation: NSEvent.mouseLocation, frame: .zero)
            return
        }

        let mouseLocation = NSEvent.mouseLocation
        // NSScreen.screens.first는 항상 프라이머리(보통 내장) 디스플레이를 반환합니다.
        // NSScreen.main은 마우스가 있는 모니터를 따라가므로, 메인 모니터로 고정하기 위해 first 사용.
        guard let mainScreen = NSScreen.screens.first else { return }
        let frame = mainScreen.frame

        guard let detectedSide = detectEdge(at: mouseLocation, frame: frame) else {
            resetAndHide(mouseLocation: mouseLocation, frame: frame)
            return
        }

        // 이미 해당 방향으로 배치된 경우 (예: 아이패드가 왼쪽에 이미 있는데 왼쪽으로 넘어갈 때) 인디케이터 스킵
        if DisplayManager.shared.currentArrangement == detectedSide {
            resetAndHide(mouseLocation: mouseLocation, frame: frame)
            return
        }

        // 엣지 인디케이터 진행도 계산
        let progress: CGFloat
        if let startDate = timerStartDate, pendingSide == detectedSide {
            progress = min(CGFloat(Date().timeIntervalSince(startDate) / triggerDelay), 1.0)
        } else {
            progress = 0
        }

        EdgeIndicatorController.shared.update(
            mouseX: mouseLocation.x,
            mouseY: mouseLocation.y,
            screenFrame: frame,
            progress: progress,
            targetSide: detectedSide
        )

        // 같은 방향으로 이미 진행 중이면 스킵
        if pendingSide == detectedSide { return }

        // 새 방향 감지: 기존 타이머 취소하고 새 타이머 시작
        debounceTimer?.invalidate()
        pendingSide = detectedSide
        timerStartDate = Date()

        debounceTimer = Timer.scheduledTimer(withTimeInterval: triggerDelay, repeats: false) { [weak self] _ in
            guard let self = self, let side = self.pendingSide else { return }
            let currentMouse = NSEvent.mouseLocation
            if self.detectEdge(at: currentMouse, frame: frame) == side {
                // 트리거 플래시 애니메이션
                EdgeIndicatorController.shared.triggerFlash(side: side)
                self.onEdgeDetected?(side)
            }
            self.pendingSide = nil
            self.timerStartDate = nil
        }
    }

    private func resetAndHide(mouseLocation: NSPoint, frame: CGRect) {
        if debounceTimer != nil {
            debounceTimer?.invalidate()
            debounceTimer = nil
            pendingSide = nil
            timerStartDate = nil
        }
        EdgeIndicatorController.shared.update(
            mouseX: mouseLocation.x,
            mouseY: mouseLocation.y,
            screenFrame: frame,
            progress: 0,
            targetSide: nil
        )
    }

    private func detectEdge(at location: NSPoint, frame: CGRect) -> DisplayManager.DisplaySide? {
        // Y좌표가 메인 화면 범위를 크게 벗어나면 감지하지 않음
        guard location.y >= frame.minY - 100 && location.y <= frame.maxY + 100 else { return nil }

        // 마우스가 완전히 다른 모니터로 넘어간 상태(예: x = -100)는 엣지가 아님.
        // 정확히 화면 가장자리(임계값 내부)에 있을 때만 엣지로 인식.
        let isAtLeftEdge = location.x >= frame.minX - edgeThreshold && location.x <= frame.minX + edgeThreshold
        let isAtRightEdge = location.x >= frame.maxX - edgeThreshold && location.x <= frame.maxX + edgeThreshold

        if isAtLeftEdge {
            return .left
        } else if isAtRightEdge {
            return .right
        }
        return nil
    }
}
