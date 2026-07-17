import Carbon
import CoreGraphics
import Foundation

final class KeyboardMonitor {
    enum StartError: LocalizedError {
        case eventTapUnavailable

        var errorDescription: String? {
            "EventTapを開始できません。アクセシビリティ権限を確認してください。"
        }
    }

    private static let spaceKeyCode: CGKeyCode = 49
    private static let syntheticMarker: Int64 = 0x48414E4B414B55
    private static let blockingModifiers: CGEventFlags = [
        .maskShift, .maskControl, .maskAlternate, .maskCommand, .maskSecondaryFn
    ]

    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private let isEnabled: () -> Bool
    var onStateChange: ((Bool, String?) -> Void)?

    init(isEnabled: @escaping () -> Bool) {
        self.isEnabled = isEnabled
    }

    var isRunning: Bool {
        guard let eventTap else { return false }
        return CGEvent.tapIsEnabled(tap: eventTap)
    }

    func start() throws {
        guard eventTap == nil else {
            if let eventTap { CGEvent.tapEnable(tap: eventTap, enable: true) }
            onStateChange?(true, nil)
            return
        }

        let mask = CGEventMask(1 << CGEventType.keyDown.rawValue)
        let pointer = Unmanaged.passUnretained(self).toOpaque()
        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: mask,
            callback: Self.callback,
            userInfo: pointer
        ) else {
            onStateChange?(false, StartError.eventTapUnavailable.localizedDescription)
            throw StartError.eventTapUnavailable
        }

        let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        eventTap = tap
        runLoopSource = source
        CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
        onStateChange?(true, nil)
    }

    func stop() {
        if let eventTap {
            CGEvent.tapEnable(tap: eventTap, enable: false)
        }
        if let runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), runLoopSource, .commonModes)
        }
        runLoopSource = nil
        eventTap = nil
        onStateChange?(false, nil)
    }

    private static let callback: CGEventTapCallBack = { _, type, event, userInfo in
        guard let userInfo else { return Unmanaged.passUnretained(event) }
        let monitor = Unmanaged<KeyboardMonitor>.fromOpaque(userInfo).takeUnretainedValue()

        if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
            if let tap = monitor.eventTap {
                CGEvent.tapEnable(tap: tap, enable: true)
                monitor.onStateChange?(true, "EventTapを再開しました")
            }
            return Unmanaged.passUnretained(event)
        }

        return monitor.handle(event: event)
            ? nil
            : Unmanaged.passUnretained(event)
    }

    /// Returns true when the original event must be cancelled.
    private func handle(event: CGEvent) -> Bool {
        guard event.getIntegerValueField(.keyboardEventKeycode) == Int64(Self.spaceKeyCode),
              event.getIntegerValueField(.eventSourceUserData) != Self.syntheticMarker,
              event.flags.intersection(Self.blockingModifiers).isEmpty,
              isEnabled(),
              InputSourceMonitor.readCurrent().isJapanese,
              !IsSecureEventInputEnabled()
        else {
            return false
        }

        postShiftSpace(keyDown: true)
        postShiftSpace(keyDown: false)
        return true
    }

    private func postShiftSpace(keyDown: Bool) {
        guard let source = CGEventSource(stateID: .hidSystemState),
              let event = CGEvent(
                keyboardEventSource: source,
                virtualKey: Self.spaceKeyCode,
                keyDown: keyDown
              )
        else { return }

        event.flags = [.maskShift]
        event.setIntegerValueField(.eventSourceUserData, value: Self.syntheticMarker)
        event.post(tap: .cghidEventTap)
    }
}
