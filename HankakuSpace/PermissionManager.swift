import AppKit
import ApplicationServices
import Foundation

final class PermissionManager: ObservableObject {
    @Published private(set) var isAccessibilityGranted = false

    func refresh() {
        isAccessibilityGranted = AXIsProcessTrusted()
    }

    func requestAccessibility() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        _ = AXIsProcessTrustedWithOptions(options)
        refresh()
    }

    func openAccessibilitySettings() {
        guard let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") else {
            return
        }
        NSWorkspace.shared.open(url)
    }
}
