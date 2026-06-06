import Cocoa

// MARK: - HUDController
/// 배치 변경 시 macOS 볼륨 HUD 스타일의 오버레이를 표시합니다.
final class HUDController {

    static let shared = HUDController()

    private var hudPanel: HUDPanel?
    private var dismissTimer: Timer?

    private init() {}

    // MARK: - Show / Hide

    func show(side: DisplayManager.DisplaySide) {
        DispatchQueue.main.async { [weak self] in
            self?.dismissTimer?.invalidate()
            self?.showHUD(side: side)
        }
    }

    private func showHUD(side: DisplayManager.DisplaySide) {
        // 기존 패널 재사용 또는 새로 생성
        let panel: HUDPanel
        if let existing = hudPanel {
            panel = existing
        } else {
            panel = HUDPanel()
            hudPanel = panel
        }

        // 콘텐츠 업데이트
        panel.update(side: side)

        // 화면 중앙 하단에 위치
        positionPanel(panel)

        // 페이드인
        panel.alphaValue = 0
        panel.orderFrontRegardless()

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            panel.animator().alphaValue = 1.0
        }

        // 자동 해제 타이머 (1.5초 후 페이드아웃)
        dismissTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { [weak self] _ in
            self?.hideHUD()
        }
    }

    func hideHUD() {
        guard let panel = hudPanel else { return }
        dismissTimer?.invalidate()
        dismissTimer = nil

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.3
            panel.animator().alphaValue = 0
        }, completionHandler: {
            panel.orderOut(nil)
        })
    }

    private func positionPanel(_ panel: HUDPanel) {
        guard let screen = NSScreen.main else { return }
        let screenFrame = screen.visibleFrame
        let panelSize = panel.frame.size

        // 화면 중앙 하단 (볼륨 HUD 스타일)
        let x = screenFrame.midX - panelSize.width / 2
        let y = screenFrame.minY + screenFrame.height * 0.15

        panel.setFrameOrigin(NSPoint(x: x, y: y))
    }
}

// MARK: - HUDPanel
/// 반투명 HUD 오버레이 패널
final class HUDPanel: NSPanel {

    private let effectView: NSVisualEffectView
    private let iconLabel: NSTextField
    private let titleLabel: NSTextField

    init() {
        let size = NSSize(width: 220, height: 100)
        let rect = NSRect(origin: .zero, size: size)

        effectView = NSVisualEffectView(frame: rect)
        iconLabel = NSTextField(frame: .zero)
        titleLabel = NSTextField(frame: .zero)

        super.init(
            contentRect: rect,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        setupPanel()
        setupContent()
    }

    private func setupPanel() {
        level = .floating
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        isOpaque = false
        backgroundColor = .clear
        hasShadow = true
        isMovable = false
        hidesOnDeactivate = false
        ignoresMouseEvents = true
    }

    private func setupContent() {
        // 배경: NSVisualEffectView (HUD 스타일)
        effectView.material = .hudWindow
        effectView.blendingMode = .behindWindow
        effectView.state = .active
        effectView.wantsLayer = true
        effectView.layer?.cornerRadius = 18
        effectView.layer?.masksToBounds = true
        contentView = effectView

        // 아이콘 레이블 (큰 화살표)
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        iconLabel.isBezeled = false
        iconLabel.isEditable = false
        iconLabel.drawsBackground = false
        iconLabel.alignment = .center
        iconLabel.font = NSFont.systemFont(ofSize: 36, weight: .light)
        iconLabel.textColor = NSColor.white.withAlphaComponent(0.95)
        effectView.addSubview(iconLabel)

        // 텍스트 레이블
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.isBezeled = false
        titleLabel.isEditable = false
        titleLabel.drawsBackground = false
        titleLabel.alignment = .center
        titleLabel.font = NSFont.systemFont(ofSize: 13, weight: .medium)
        titleLabel.textColor = NSColor.white.withAlphaComponent(0.9)
        effectView.addSubview(titleLabel)

        // 레이아웃
        NSLayoutConstraint.activate([
            iconLabel.centerXAnchor.constraint(equalTo: effectView.centerXAnchor),
            iconLabel.topAnchor.constraint(equalTo: effectView.topAnchor, constant: 16),
            iconLabel.heightAnchor.constraint(equalToConstant: 44),

            titleLabel.centerXAnchor.constraint(equalTo: effectView.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 4),
            titleLabel.leadingAnchor.constraint(equalTo: effectView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: effectView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: effectView.bottomAnchor, constant: -16)
        ])
    }

    func update(side: DisplayManager.DisplaySide) {
        switch side {
        case .left:
            iconLabel.stringValue = "◀"
            titleLabel.stringValue = L(.hudLeft)
        case .right:
            iconLabel.stringValue = "▶"
            titleLabel.stringValue = L(.hudRight)
        }
    }
}
