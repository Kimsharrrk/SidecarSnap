import Cocoa

// SidecarSnap 진입점
// NSApplicationMain을 수동으로 설정합니다.
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
