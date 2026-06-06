import Cocoa

// MARK: - EdgeIndicatorController
/// 마우스가 메인 디스플레이 끝에 닿을 때 다이나믹 아일랜드 스타일의 물방울(Blob) 애니메이션을 표시합니다.
final class EdgeIndicatorController {

    static let shared = EdgeIndicatorController()

    private var leftPanel: BlobPanel?
    private var rightPanel: BlobPanel?

    private init() {}

    // MARK: - Setup

    func setup() {
        DispatchQueue.main.async { [weak self] in
            self?.createPanels()
        }
    }

    func teardown() {
        leftPanel?.orderOut(nil)
        rightPanel?.orderOut(nil)
        leftPanel = nil
        rightPanel = nil
    }

    private func createPanels() {
        // 메인(내장) 디스플레이에서만 동작
        guard let screen = NSScreen.screens.first else { return }
        let frame = screen.frame

        leftPanel = BlobPanel(side: .left, screenFrame: frame)
        rightPanel = BlobPanel(side: .right, screenFrame: frame)
    }

    // MARK: - Update

    /// 마우스 위치와 타이머 진행도에 따라 물방울 애니메이션을 업데이트합니다.
    func update(mouseX: CGFloat, mouseY: CGFloat, screenFrame: CGRect, progress: CGFloat, targetSide: DisplayManager.DisplaySide?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            if targetSide == .left {
                self.leftPanel?.updateBlob(mouseY: mouseY, progress: progress)
                self.rightPanel?.hideBlob()
            } else if targetSide == .right {
                self.rightPanel?.updateBlob(mouseY: mouseY, progress: progress)
                self.leftPanel?.hideBlob()
            } else {
                self.hideAll()
            }
        }
    }

    /// 배치 변경 트리거 시 통통 튀는 플래시 애니메이션
    func triggerFlash(side: DisplayManager.DisplaySide) {
        DispatchQueue.main.async { [weak self] in
            let panel = side == .left ? self?.leftPanel : self?.rightPanel
            panel?.playTriggerAnimation()
        }
    }

    /// 모든 인디케이터 숨기기
    func hideAll() {
        DispatchQueue.main.async { [weak self] in
            self?.leftPanel?.hideBlob()
            self?.rightPanel?.hideBlob()
        }
    }
}

// MARK: - BlobPanel
/// 다이나믹 아일랜드 스타일의 베젤에서 튀어나오는 검은색 물방울 패널
final class BlobPanel: NSPanel {

    private let side: DisplayManager.DisplaySide
    private let blobLayer = CAShapeLayer()
    private var screenFrame: CGRect

    private let panelWidth: CGFloat = 80

    init(side: DisplayManager.DisplaySide, screenFrame: CGRect) {
        self.side = side
        self.screenFrame = screenFrame

        let x: CGFloat = side == .left
            ? screenFrame.minX
            : screenFrame.maxX - panelWidth

        let rect = CGRect(x: x, y: screenFrame.minY,
                          width: panelWidth, height: screenFrame.height)

        super.init(
            contentRect: rect,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.maximumWindow)) + 1)
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        isOpaque = false
        backgroundColor = .clear
        hasShadow = false
        ignoresMouseEvents = true
        alphaValue = 1.0

        setupLayers()
        orderFrontRegardless()
    }

    private func setupLayers() {
        guard let contentView = contentView else { return }
        contentView.wantsLayer = true

        blobLayer.fillColor = NSColor.black.cgColor
        blobLayer.opacity = 0
        
        // 부드러운 애니메이션을 위한 액션 비활성화 (수동 제어)
        blobLayer.actions = ["path": NSNull(), "opacity": NSNull()]

        contentView.layer?.addSublayer(blobLayer)
    }

    // MARK: - Appearance

    func updateBlob(mouseY: CGFloat, progress: CGFloat) {
        // AppKit 좌표계에서 Y축은 아래에서 위로 증가합니다.
        // 마우스 Y 좌표를 패널 내 로컬 좌표로 변환
        let localY = mouseY - screenFrame.minY
        
        // 진행도에 따른 물방울 크기 계산 (기본 12px 튀어나옴 + 진행도에 따라 최대 40px까지 팽창)
        let blobWidth = 12.0 + (28.0 * progress)
        let blobHeight = 100.0 + (40.0 * progress)
        
        let path = createBlobPath(centerY: localY, width: blobWidth, height: blobHeight)
        
        blobLayer.path = path
        
        if blobLayer.opacity == 0 {
            // 처음 나타날 때 약간의 페이드인
            let anim = CABasicAnimation(keyPath: "opacity")
            anim.fromValue = 0
            anim.toValue = 1
            anim.duration = 0.1
            blobLayer.add(anim, forKey: "fadeIn")
            blobLayer.opacity = 1
        }
    }
    
    func hideBlob() {
        if blobLayer.opacity > 0 {
            let anim = CABasicAnimation(keyPath: "opacity")
            anim.fromValue = 1
            anim.toValue = 0
            anim.duration = 0.15
            blobLayer.add(anim, forKey: "fadeOut")
            blobLayer.opacity = 0
        }
    }

    // MARK: - Path Generation
    
    private func createBlobPath(centerY: CGFloat, width: CGFloat, height: CGFloat) -> CGPath {
        let path = CGMutablePath()
        let halfHeight = height / 2.0
        
        let startY = centerY - halfHeight
        let endY = centerY + halfHeight
        
        let cpOffset: CGFloat = height * 0.25 // 곡선 제어점 오프셋
        
        if side == .left {
            // 왼쪽 엣지 (X=0에서 우측으로 튀어나옴)
            path.move(to: CGPoint(x: 0, y: startY))
            
            // 물방울 위쪽 곡선 -> 꼭대기 -> 아래쪽 곡선
            path.addCurve(to: CGPoint(x: width, y: centerY),
                          control1: CGPoint(x: 0, y: startY + cpOffset),
                          control2: CGPoint(x: width, y: centerY - cpOffset))
            
            path.addCurve(to: CGPoint(x: 0, y: endY),
                          control1: CGPoint(x: width, y: centerY + cpOffset),
                          control2: CGPoint(x: 0, y: endY - cpOffset))
            
            path.addLine(to: CGPoint(x: 0, y: startY))
            
        } else {
            // 오른쪽 엣지 (X=panelWidth에서 좌측으로 튀어나옴)
            let baseX = panelWidth
            let targetX = panelWidth - width
            
            path.move(to: CGPoint(x: baseX, y: startY))
            
            path.addCurve(to: CGPoint(x: targetX, y: centerY),
                          control1: CGPoint(x: baseX, y: startY + cpOffset),
                          control2: CGPoint(x: targetX, y: centerY - cpOffset))
            
            path.addCurve(to: CGPoint(x: baseX, y: endY),
                          control1: CGPoint(x: targetX, y: centerY + cpOffset),
                          control2: CGPoint(x: baseX, y: endY - cpOffset))
            
            path.addLine(to: CGPoint(x: baseX, y: startY))
        }
        
        path.closeSubpath()
        return path
    }

    // MARK: - Trigger Animation

    func playTriggerAnimation() {
        // 통통 튀는(젤리 같은) 애니메이션 후 사라짐
        guard let currentPath = blobLayer.path else { return }
        
        // 현재 Y 좌표 근사값 구하기 (path의 bounding box 중앙)
        let bounds = currentPath.boundingBox
        let centerY = bounds.midY
        
        // 크기가 확 커지는 path
        let expandedWidth: CGFloat = 60.0
        let expandedHeight: CGFloat = 180.0
        let expandedPath = createBlobPath(centerY: centerY, width: expandedWidth, height: expandedHeight)
        
        let anim = CABasicAnimation(keyPath: "path")
        anim.fromValue = currentPath
        anim.toValue = expandedPath
        anim.duration = 0.15
        anim.timingFunction = CAMediaTimingFunction(name: .easeOut)
        
        blobLayer.path = expandedPath
        blobLayer.add(anim, forKey: "expand")
        
        // 0.15초 후 줄어들면서 사라짐
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            let shrinkAnim = CABasicAnimation(keyPath: "path")
            shrinkAnim.fromValue = expandedPath
            let shrinkPath = self.createBlobPath(centerY: centerY, width: 0, height: 0)
            shrinkAnim.toValue = shrinkPath
            shrinkAnim.duration = 0.2
            shrinkAnim.timingFunction = CAMediaTimingFunction(name: .easeIn)
            
            let fadeAnim = CABasicAnimation(keyPath: "opacity")
            fadeAnim.fromValue = 1
            fadeAnim.toValue = 0
            fadeAnim.duration = 0.2
            
            self.blobLayer.path = shrinkPath
            self.blobLayer.opacity = 0
            
            self.blobLayer.add(shrinkAnim, forKey: "shrink")
            self.blobLayer.add(fadeAnim, forKey: "fade")
        }
    }
}
