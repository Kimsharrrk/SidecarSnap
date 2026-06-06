import Cocoa

// MARK: - AppDelegate
final class AppDelegate: NSObject, NSApplicationDelegate {

    private var statusBarController: StatusBarController!
    private var screenChangeObserver: NSObjectProtocol?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSLog("[SidecarSnap] 앱 시작 v1.1")

        // 메뉴바 앱이므로 Dock 아이콘 숨기기
        NSApp.setActivationPolicy(.accessory)

        // 접근성 권한 확인 (소리 없이)
        let trusted = AXIsProcessTrusted()
        NSLog("[SidecarSnap] 접근성 권한: \(trusted ? "허용됨" : "미허용")")

        // 메뉴바 컨트롤러 초기화
        statusBarController = StatusBarController()

        // 이미 실행 중인데 다시 실행된 경우 아이콘 복구
        NotificationCenter.default.addObserver(self, selector: #selector(handleReopen), name: NSApplication.willBecomeActiveNotification, object: nil)

        // 초기 디스플레이 탐지
        let sidecarFound = DisplayManager.shared.refreshDisplays()
        NSLog("[SidecarSnap] 초기 디스플레이 탐지: Sidecar \(sidecarFound ? "발견" : "없음")")

        // 마우스 모니터링 시작
        MouseEdgeMonitor.shared.isEnabled = true
        MouseEdgeMonitor.shared.onEdgeDetected = { [weak self] side in
            self?.handleEdgeDetected(side: side)
        }

        // 화면 구성 변경 알림 구독 (Sidecar 연결/해제 감지)
        screenChangeObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleScreenChange()
        }

        // 온보딩 표시 (첫 실행 시에만)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            OnboardingController.showIfNeeded()
        }

        statusBarController.updateStatus()
    }

    func applicationWillTerminate(_ notification: Notification) {
        MouseEdgeMonitor.shared.isEnabled = false
        if let observer = screenChangeObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        NotificationCenter.default.removeObserver(self)
        NSLog("[SidecarSnap] 앱 종료")
    }

    func rebuildMenu() {
        statusBarController.rebuildMenu()
    }

    @objc private func handleReopen() {
        statusBarController.showIconIfNeeded()
    }

    // MARK: - Event Handlers

    private func handleEdgeDetected(side: DisplayManager.DisplaySide) {
        guard DisplayManager.shared.isSidecarConnected else {
            NSLog("[SidecarSnap] 엣지 감지됐지만 Sidecar 미연결")
            return
        }

        let sideName = side == .left ? "왼쪽" : "오른쪽"
        NSLog("[SidecarSnap] 엣지 감지: \(sideName) → Sidecar 배치 변경")

        DisplayManager.shared.arrangeSidecar(to: side)

        statusBarController.updateStatus()
    }

    private func handleScreenChange() {
        NSLog("[SidecarSnap] 화면 구성 변경 감지")
        let sidecarFound = DisplayManager.shared.refreshDisplays()
        NSLog("[SidecarSnap] Sidecar 상태: \(sidecarFound ? "연결됨" : "연결 안됨")")
        statusBarController.updateStatus()
    }
}
