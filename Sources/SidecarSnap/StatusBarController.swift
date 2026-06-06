import Cocoa
import ServiceManagement

// MARK: - StatusBarController
final class StatusBarController {

    private var statusBar: NSStatusBar
    private var statusItem: NSStatusItem
    private var menu: NSMenu

    private var connectionStatusItem: NSMenuItem!
    private var arrangementStatusItem: NSMenuItem!
    private var autoToggleItem: NSMenuItem!
    private var manualLeftItem: NSMenuItem!
    private var manualRightItem: NSMenuItem!
    private var launchAtLoginItem: NSMenuItem!
    private var hideIconItem: NSMenuItem!

    init() {
        statusBar = NSStatusBar.system
        statusItem = statusBar.statusItem(withLength: NSStatusItem.variableLength)
        menu = NSMenu()
        setupStatusItem()
        setupMenu()
        updateStatus()

        // 시작 시 아이콘 숨김 상태 적용
        if UserDefaults.standard.bool(forKey: "hideMenuBarIcon") {
            statusItem.isVisible = false
        }
    }

    // MARK: - Setup

    private func setupStatusItem() {
        guard let button = statusItem.button else { return }
        if let image = NSImage(systemSymbolName: "ipad.and.iphone", accessibilityDescription: "SidecarSnap") {
            image.isTemplate = true
            button.image = image
        } else {
            button.title = "⇔"
        }
        button.toolTip = "SidecarSnap"
        statusItem.menu = menu
    }

    func rebuildMenu() {
        setupMenu()
        updateStatus()
    }

    func showIconIfNeeded() {
        if UserDefaults.standard.bool(forKey: "hideMenuBarIcon") {
            UserDefaults.standard.set(false, forKey: "hideMenuBarIcon")
            statusItem.isVisible = true
            NSLog("[SidecarSnap] 앱 재실행으로 아이콘 숨김 해제")
        }
    }

    private func setupMenu() {
        menu.removeAllItems()

        // 타이틀
        let titleItem = NSMenuItem(title: "SidecarSnap", action: nil, keyEquivalent: "")
        titleItem.isEnabled = false
        titleItem.attributedTitle = NSAttributedString(
            string: "SidecarSnap  \(L(.version))",
            attributes: [.font: NSFont.boldSystemFont(ofSize: 13), .foregroundColor: NSColor.labelColor]
        )
        menu.addItem(titleItem)
        menu.addItem(NSMenuItem.separator())

        // 상태
        connectionStatusItem = NSMenuItem(title: L(.detecting), action: nil, keyEquivalent: "")
        connectionStatusItem.isEnabled = false
        menu.addItem(connectionStatusItem!)

        arrangementStatusItem = NSMenuItem(title: L(.arrangementNone), action: nil, keyEquivalent: "")
        arrangementStatusItem.isEnabled = false
        menu.addItem(arrangementStatusItem!)
        menu.addItem(NSMenuItem.separator())

        // 자동 감지
        autoToggleItem = NSMenuItem(title: L(.autoDetectOn), action: #selector(toggleAutoDetect), keyEquivalent: "t")
        autoToggleItem.target = self
        autoToggleItem.state = .on
        menu.addItem(autoToggleItem!)
        menu.addItem(NSMenuItem.separator())

        // 수동 배치
        let manualHeader = NSMenuItem(title: L(.manualArrange), action: nil, keyEquivalent: "")
        manualHeader.isEnabled = false
        menu.addItem(manualHeader)

        manualLeftItem = NSMenuItem(title: L(.moveLeft), action: #selector(manualLeft), keyEquivalent: "[")
        manualLeftItem.target = self
        menu.addItem(manualLeftItem!)

        manualRightItem = NSMenuItem(title: L(.moveRight), action: #selector(manualRight), keyEquivalent: "]")
        manualRightItem.target = self
        menu.addItem(manualRightItem!)
        menu.addItem(NSMenuItem.separator())

        // 설정
        let settingsHeader = NSMenuItem(title: L(.settings), action: nil, keyEquivalent: "")
        settingsHeader.isEnabled = false
        menu.addItem(settingsHeader)

        let d03 = NSMenuItem(title: L(.delay03), action: #selector(setDelay03), keyEquivalent: "")
        d03.target = self; menu.addItem(d03)

        let d05 = NSMenuItem(title: L(.delay05), action: #selector(setDelay05), keyEquivalent: "")
        d05.target = self; menu.addItem(d05)

        let d10 = NSMenuItem(title: L(.delay10), action: #selector(setDelay10), keyEquivalent: "")
        d10.target = self; menu.addItem(d10)

        menu.addItem(NSMenuItem.separator())

        launchAtLoginItem = NSMenuItem(title: L(.launchAtLogin), action: #selector(toggleLaunchAtLogin), keyEquivalent: "")
        launchAtLoginItem.target = self
        launchAtLoginItem.state = isLaunchAtLoginEnabled ? .on : .off
        menu.addItem(launchAtLoginItem!)

        hideIconItem = NSMenuItem(title: L(.hideIcon), action: #selector(hideMenuBarIcon), keyEquivalent: "")
        hideIconItem.target = self
        menu.addItem(hideIconItem!)

        let hideJokeItem = NSMenuItem(title: L(.hideIconJoke), action: nil, keyEquivalent: "")
        hideJokeItem.isEnabled = false
        hideJokeItem.attributedTitle = NSAttributedString(
            string: L(.hideIconJoke),
            attributes: [.font: NSFont.systemFont(ofSize: 11), .foregroundColor: NSColor.secondaryLabelColor]
        )
        menu.addItem(hideJokeItem)

        let accessItem = NSMenuItem(title: L(.checkAccessibility), action: #selector(checkAccessibility), keyEquivalent: "")
        accessItem.target = self; menu.addItem(accessItem)

        let onboardItem = NSMenuItem(title: L(.startGuide), action: #selector(showOnboarding), keyEquivalent: "")
        onboardItem.target = self; menu.addItem(onboardItem)

        menu.addItem(NSMenuItem.separator())

        // 언어 서브메뉴
        let langItem = NSMenuItem(title: L(.language), action: nil, keyEquivalent: "")
        let langSubmenu = NSMenu()
        for lang in AppLanguage.allCases {
            let item = NSMenuItem(title: lang.displayName, action: #selector(changeLanguage(_:)), keyEquivalent: "")
            item.target = self
            item.tag = AppLanguage.allCases.firstIndex(of: lang) ?? 0
            item.state = LocalizationManager.shared.currentLanguage == lang ? .on : .off
            langSubmenu.addItem(item)
        }
        langItem.submenu = langSubmenu
        menu.addItem(langItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: L(.quit), action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        menu.addItem(quitItem)
    }

    // MARK: - Status Update

    func updateStatus() {
        let dm = DisplayManager.shared
        let monitor = MouseEdgeMonitor.shared

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            if dm.isSidecarConnected {
                let name = dm.sidecarDisplay?.name ?? "iPad"
                self.connectionStatusItem.title = L(.sidecarConnected).replacingOccurrences(of: "Connected", with: name)
                    .replacingOccurrences(of: "연결됨", with: name)
                    .replacingOccurrences(of: "接続中", with: name)
                // simpler approach:
                let connStr: String
                switch LocalizationManager.shared.currentLanguage {
                case .english:  connStr = "✅ Sidecar: \(name)"
                case .korean:   connStr = "✅ Sidecar: \(name)"
                case .japanese: connStr = "✅ Sidecar: \(name)"
                }
                self.connectionStatusItem.title = connStr
                self.arrangementStatusItem.title = dm.currentArrangement == .left ? L(.arrangementLeft) : L(.arrangementRight)
                self.manualLeftItem.isEnabled = true
                self.manualRightItem.isEnabled = true
            } else {
                self.connectionStatusItem.title = L(.sidecarDisconnected)
                self.arrangementStatusItem.title = L(.arrangementNone)
                self.manualLeftItem.isEnabled = false
                self.manualRightItem.isEnabled = false
            }

            self.autoToggleItem.state = monitor.isEnabled ? .on : .off
            self.launchAtLoginItem.state = self.isLaunchAtLoginEnabled ? .on : .off
            self.updateMenuBarIcon(connected: dm.isSidecarConnected, side: dm.currentArrangement)
        }
    }

    private func updateMenuBarIcon(connected: Bool, side: DisplayManager.DisplaySide) {
        guard let button = statusItem.button else { return }
        if connected {
            let symbolName = side == .left ? "ipad.and.iphone" : "iphone.and.ipad"
            if let image = NSImage(systemSymbolName: symbolName, accessibilityDescription: "SidecarSnap") {
                image.isTemplate = true
                button.image = image
            }
        } else {
            if let image = NSImage(systemSymbolName: "ipad.slash", accessibilityDescription: "SidecarSnap") {
                image.isTemplate = true
                button.image = image
            }
        }
    }

    // MARK: - Launch at Login

    private var isLaunchAtLoginEnabled: Bool {
        if #available(macOS 13.0, *) { return SMAppService.mainApp.status == .enabled }
        return false
    }

    @objc private func toggleLaunchAtLogin() {
        if #available(macOS 13.0, *) {
            do {
                if SMAppService.mainApp.status == .enabled {
                    try SMAppService.mainApp.unregister()
                } else {
                    try SMAppService.mainApp.register()
                }
                launchAtLoginItem.state = isLaunchAtLoginEnabled ? .on : .off
            } catch { NSLog("[SidecarSnap] Login item error: \(error)") }
        }
    }

    // MARK: - Actions

    @objc private func toggleAutoDetect() {
        MouseEdgeMonitor.shared.isEnabled.toggle()
        autoToggleItem.state = MouseEdgeMonitor.shared.isEnabled ? .on : .off
    }

    @objc private func manualLeft() {
        DisplayManager.shared.arrangeSidecar(to: .left)
        updateStatus()
    }

    @objc private func manualRight() {
        DisplayManager.shared.arrangeSidecar(to: .right)
        updateStatus()
    }

    @objc private func hideMenuBarIcon() {
        let alert = NSAlert()
        alert.messageText = "Hide Icon?"
        alert.informativeText = "If you hide the icon, you can bring it back by running the SidecarSnap app again from the Applications folder."
        alert.addButton(withTitle: "Hide")
        alert.addButton(withTitle: "Cancel")
        if alert.runModal() == .alertFirstButtonReturn {
            UserDefaults.standard.set(true, forKey: "hideMenuBarIcon")
            statusItem.isVisible = false
            NSLog("[SidecarSnap] 아이콘 숨김 처리됨")
        }
    }

    @objc private func setDelay03() { MouseEdgeMonitor.shared.triggerDelay = 0.3 }
    @objc private func setDelay05() { MouseEdgeMonitor.shared.triggerDelay = 0.5 }
    @objc private func setDelay10() { MouseEdgeMonitor.shared.triggerDelay = 1.0 }

    @objc private func changeLanguage(_ sender: NSMenuItem) {
        let langs = AppLanguage.allCases
        guard sender.tag < langs.count else { return }
        LocalizationManager.shared.currentLanguage = langs[sender.tag]
        rebuildMenu()
    }

    @objc private func checkAccessibility() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        let trusted = AXIsProcessTrustedWithOptions(options as CFDictionary)
        let alert = NSAlert()
        if !trusted {
            alert.messageText = L(.accessibilityAlertTitle)
            alert.informativeText = L(.accessibilityAlertBody)
            alert.alertStyle = .warning
            alert.addButton(withTitle: L(.openSettings))
            alert.addButton(withTitle: L(.later))
            if alert.runModal() == .alertFirstButtonReturn {
                NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
            }
        } else {
            alert.messageText = L(.accessibilityOkTitle)
            alert.informativeText = L(.accessibilityOkBody)
            alert.alertStyle = .informational
            alert.addButton(withTitle: L(.ok))
            alert.runModal()
        }
    }

    @objc private func showOnboarding() {
        UserDefaults.standard.removeObject(forKey: OnboardingController.hasShownOnboardingKey)
        OnboardingController.showIfNeeded()
    }
}
