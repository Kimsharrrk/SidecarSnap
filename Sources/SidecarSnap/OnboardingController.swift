import Cocoa

// MARK: - OnboardingController
/// 첫 실행 시 사용자에게 앱 사용법과 권한 안내를 제공하는 온보딩 창
final class OnboardingController: NSWindowController {

    static let hasShownOnboardingKey = "hasShownOnboarding_v1"

    static func showIfNeeded() {
        guard !UserDefaults.standard.bool(forKey: hasShownOnboardingKey) else { return }
        let controller = OnboardingController()
        controller.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    convenience init() {
        let window = OnboardingWindow()
        self.init(window: window)
    }

    override func showWindow(_ sender: Any?) {
        super.showWindow(sender)
        window?.center()
        window?.makeKeyAndOrderFront(nil)
    }
}

// MARK: - OnboardingWindow
final class OnboardingWindow: NSWindow {

    init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 620),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        title = L(.appName)
        isReleasedWhenClosed = false
        setupContent()
    }

    private func setupContent() {
        let contentView = OnboardingView(frame: self.contentView!.bounds)
        contentView.onComplete = { [weak self] in
            UserDefaults.standard.set(true, forKey: OnboardingController.hasShownOnboardingKey)
            self?.close()
        }
        self.contentView = contentView
    }
}

// MARK: - OnboardingView
final class OnboardingView: NSView {

    var onComplete: (() -> Void)?

    private let backgroundView = NSVisualEffectView()
    private let iconView = NSImageView()
    private let titleLabel = NSTextField()
    private let subtitleLabel = NSTextField()
    
    private let languageSegmentedControl = NSSegmentedControl()

    private var step1View: StepView!
    private var step2View: StepView!
    private var step3View: StepView!
    
    private let accessibilityButton = NSButton()
    private let startButton = NSButton()
    private let accessibilityStatusLabel = NSTextField()

    override init(frame: NSRect) {
        super.init(frame: frame)
        setupUI()
        startAccessibilityCheckTimer()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        wantsLayer = true
        layer?.backgroundColor = NSColor(red: 0.08, green: 0.08, blue: 0.12, alpha: 1).cgColor

        // 배경 그라데이션 레이어
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [
            NSColor(red: 0.1, green: 0.1, blue: 0.25, alpha: 1).cgColor,
            NSColor(red: 0.05, green: 0.05, blue: 0.15, alpha: 1).cgColor
        ]
        gradientLayer.locations = [0, 1]
        layer?.addSublayer(gradientLayer)
        
        // 언어 선택 세그먼트 컨트롤
        let langs = AppLanguage.allCases
        languageSegmentedControl.segmentCount = langs.count
        for (i, lang) in langs.enumerated() {
            languageSegmentedControl.setLabel(lang.displayName, forSegment: i)
        }
        languageSegmentedControl.selectedSegment = langs.firstIndex(of: LocalizationManager.shared.currentLanguage) ?? 0
        languageSegmentedControl.target = self
        languageSegmentedControl.action = #selector(languageChanged)
        languageSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        addSubview(languageSegmentedControl)

        // 앱 아이콘
        iconView.translatesAutoresizingMaskIntoConstraints = false
        if let image = NSImage(systemSymbolName: "ipad.and.iphone", accessibilityDescription: nil) {
            let config = NSImage.SymbolConfiguration(pointSize: 64, weight: .light)
            iconView.image = image.withSymbolConfiguration(config)
            iconView.contentTintColor = NSColor(red: 0.5, green: 0.6, blue: 1.0, alpha: 1)
        }
        addSubview(iconView)

        // 타이틀
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.isBezeled = false
        titleLabel.isEditable = false
        titleLabel.drawsBackground = false
        titleLabel.alignment = .center
        titleLabel.font = NSFont.systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = .white
        addSubview(titleLabel)

        // 서브타이틀
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.isBezeled = false
        subtitleLabel.isEditable = false
        subtitleLabel.drawsBackground = false
        subtitleLabel.alignment = .center
        subtitleLabel.font = NSFont.systemFont(ofSize: 13, weight: .regular)
        subtitleLabel.textColor = NSColor.white.withAlphaComponent(0.6)
        addSubview(subtitleLabel)

        // 스텝 뷰들
        step1View = StepView(number: "1", title: "", description: "")
        step2View = StepView(number: "2", title: "", description: "")
        step3View = StepView(number: "3", title: "", description: "")
        [step1View, step2View, step3View].forEach {
            $0!.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0!)
        }

        // 접근성 상태 레이블
        accessibilityStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        accessibilityStatusLabel.isBezeled = false
        accessibilityStatusLabel.isEditable = false
        accessibilityStatusLabel.drawsBackground = false
        accessibilityStatusLabel.alignment = .center
        accessibilityStatusLabel.font = NSFont.systemFont(ofSize: 11)
        addSubview(accessibilityStatusLabel)

        // 접근성 버튼
        accessibilityButton.translatesAutoresizingMaskIntoConstraints = false
        accessibilityButton.bezelStyle = .rounded
        accessibilityButton.controlSize = .regular
        accessibilityButton.font = NSFont.systemFont(ofSize: 13, weight: .medium)
        accessibilityButton.target = self
        accessibilityButton.action = #selector(requestAccessibility)
        accessibilityButton.wantsLayer = true
        accessibilityButton.layer?.backgroundColor = NSColor(red: 0.3, green: 0.4, blue: 0.9, alpha: 1).cgColor
        accessibilityButton.layer?.cornerRadius = 8
        addSubview(accessibilityButton)

        // 시작 버튼
        startButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.bezelStyle = .rounded
        startButton.controlSize = .large
        startButton.font = NSFont.systemFont(ofSize: 15, weight: .semibold)
        startButton.target = self
        startButton.action = #selector(startApp)
        startButton.wantsLayer = true
        startButton.layer?.backgroundColor = NSColor(red: 0.4, green: 0.5, blue: 1.0, alpha: 1).cgColor
        startButton.layer?.cornerRadius = 10
        addSubview(startButton)

        setupConstraints()
        updateTexts()
        updateAccessibilityStatus()
    }

    private func setupConstraints() {
        let stackSpacing: CGFloat = 12

        NSLayoutConstraint.activate([
            languageSegmentedControl.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            languageSegmentedControl.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            iconView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconView.topAnchor.constraint(equalTo: languageSegmentedControl.bottomAnchor, constant: 20),
            iconView.widthAnchor.constraint(equalToConstant: 80),
            iconView.heightAnchor.constraint(equalToConstant: 80),

            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),

            subtitleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),

            step1View.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 24),
            step1View.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            step1View.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -28),
            step1View.heightAnchor.constraint(equalToConstant: 60),

            step2View.topAnchor.constraint(equalTo: step1View.bottomAnchor, constant: stackSpacing),
            step2View.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            step2View.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -28),
            step2View.heightAnchor.constraint(equalToConstant: 60),

            step3View.topAnchor.constraint(equalTo: step2View.bottomAnchor, constant: stackSpacing),
            step3View.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            step3View.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -28),
            step3View.heightAnchor.constraint(equalToConstant: 60),

            accessibilityStatusLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            accessibilityStatusLabel.topAnchor.constraint(equalTo: step3View.bottomAnchor, constant: 20),

            accessibilityButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            accessibilityButton.topAnchor.constraint(equalTo: accessibilityStatusLabel.bottomAnchor, constant: 8),
            accessibilityButton.widthAnchor.constraint(equalToConstant: 200),
            accessibilityButton.heightAnchor.constraint(equalToConstant: 32),

            startButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            startButton.topAnchor.constraint(equalTo: accessibilityButton.bottomAnchor, constant: 12),
            startButton.widthAnchor.constraint(equalToConstant: 200),
            startButton.heightAnchor.constraint(equalToConstant: 44),
            startButton.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -28)
        ])
    }

    private func updateTexts() {
        titleLabel.stringValue = L(.onboardingTitle)
        subtitleLabel.stringValue = L(.onboardingSubtitle)
        
        step1View.updateText(title: L(.step1Title), description: L(.step1Desc))
        step2View.updateText(title: L(.step2Title), description: L(.step2Desc))
        step3View.updateText(title: L(.step3Title), description: L(.step3Desc))
        
        accessibilityButton.title = L(.grantAccessibility)
        startButton.title = L(.startButton)
        
        updateAccessibilityStatus()
    }
    
    // MARK: - Actions
    
    @objc private func languageChanged() {
        let index = languageSegmentedControl.selectedSegment
        let langs = AppLanguage.allCases
        guard index >= 0 && index < langs.count else { return }
        LocalizationManager.shared.currentLanguage = langs[index]
        updateTexts()
        
        // 메뉴도 즉시 리빌드하기 위해 노티피케이션 (앱 델리게이트에서 처리 등 가능)
        // 여기선 단순하게 처리
        if let delegate = NSApp.delegate as? AppDelegate {
            delegate.rebuildMenu()
        }
    }

    @objc private func requestAccessibility() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        AXIsProcessTrustedWithOptions(options as CFDictionary)
    }

    @objc private func startApp() {
        onComplete?()
    }

    // MARK: - Accessibility Status

    private func startAccessibilityCheckTimer() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateAccessibilityStatus()
        }
    }

    private func updateAccessibilityStatus() {
        DispatchQueue.main.async { [weak self] in
            let trusted = AXIsProcessTrusted()
            if trusted {
                self?.accessibilityStatusLabel.stringValue = L(.accessibilityGranted)
                self?.accessibilityStatusLabel.textColor = NSColor(red: 0.3, green: 0.9, blue: 0.5, alpha: 1)
                self?.accessibilityButton.isEnabled = false
                self?.accessibilityButton.alphaValue = 0.4
            } else {
                self?.accessibilityStatusLabel.stringValue = L(.accessibilityNeeded)
                self?.accessibilityStatusLabel.textColor = NSColor(red: 1.0, green: 0.7, blue: 0.3, alpha: 1)
                self?.accessibilityButton.isEnabled = true
                self?.accessibilityButton.alphaValue = 1.0
            }
        }
    }
}

// MARK: - StepView
/// 온보딩 스텝 뷰 (번호 + 타이틀 + 설명)
final class StepView: NSView {
    
    private let titleLabel = NSTextField()
    private let descLabel = NSTextField()

    init(number: String, title: String, description: String) {
        super.init(frame: .zero)
        setupUI(number: number, title: title, description: description)
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI(number: String, title: String, description: String) {
        wantsLayer = true
        layer?.backgroundColor = NSColor.white.withAlphaComponent(0.05).cgColor
        layer?.cornerRadius = 12

        let numberLabel = NSTextField()
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        numberLabel.stringValue = number
        numberLabel.isBezeled = false
        numberLabel.isEditable = false
        numberLabel.drawsBackground = false
        numberLabel.alignment = .center
        numberLabel.font = NSFont.monospacedSystemFont(ofSize: 16, weight: .bold)
        numberLabel.textColor = NSColor(red: 0.5, green: 0.6, blue: 1.0, alpha: 1)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.stringValue = title
        titleLabel.isBezeled = false
        titleLabel.isEditable = false
        titleLabel.drawsBackground = false
        titleLabel.font = NSFont.systemFont(ofSize: 13, weight: .semibold)
        titleLabel.textColor = .white

        descLabel.translatesAutoresizingMaskIntoConstraints = false
        descLabel.stringValue = description
        descLabel.isBezeled = false
        descLabel.isEditable = false
        descLabel.drawsBackground = false
        descLabel.font = NSFont.systemFont(ofSize: 11)
        descLabel.textColor = NSColor.white.withAlphaComponent(0.55)
        descLabel.usesSingleLineMode = false
        descLabel.lineBreakMode = .byWordWrapping

        [numberLabel, titleLabel, descLabel].forEach { addSubview($0) }

        NSLayoutConstraint.activate([
            numberLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            numberLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            numberLabel.widthAnchor.constraint(equalToConstant: 28),

            titleLabel.leadingAnchor.constraint(equalTo: numberLabel.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            descLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            descLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            descLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -10)
        ])
    }
    
    func updateText(title: String, description: String) {
        titleLabel.stringValue = title
        descLabel.stringValue = description
    }
}
