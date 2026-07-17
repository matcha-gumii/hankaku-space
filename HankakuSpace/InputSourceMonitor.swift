import AppKit
import Carbon
import Foundation

struct InputSourceState: Equatable {
    let identifier: String
    let modeIdentifier: String
    let localizedName: String
    let languages: [String]

    var isJapanese: Bool {
        let source = identifier.lowercased()
        let mode = modeIdentifier.lowercased()

        // A Japanese IME can expose an explicit ASCII/Roman sub-mode.
        let isRomanMode = mode.contains("roman")
            || mode.contains("ascii")
            || mode.contains("alphanumeric")
            || mode.contains("eisu")
        if isRomanMode || source.contains("com.apple.keylayout") {
            return false
        }

        return languages.contains { $0.lowercased().hasPrefix("ja") }
            || source.contains("japanese")
            || source.contains("kotoeri")
            || source.contains("atok")
            || source.contains("googlejapaneseinput")
            || mode.contains("japanese")
    }

    static let unknown = InputSourceState(
        identifier: "unknown",
        modeIdentifier: "",
        localizedName: "不明",
        languages: []
    )
}

final class InputSourceMonitor: ObservableObject {
    @Published private(set) var current: InputSourceState = .unknown
    private var observer: NSObjectProtocol?

    init() {
        refresh()
        observer = DistributedNotificationCenter.default().addObserver(
            forName: Notification.Name(kTISNotifySelectedKeyboardInputSourceChanged as String),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.refresh()
        }
    }

    deinit {
        if let observer {
            DistributedNotificationCenter.default().removeObserver(observer)
        }
    }

    func refresh() {
        current = Self.readCurrent()
    }

    static func readCurrent() -> InputSourceState {
        guard let unmanaged = TISCopyCurrentKeyboardInputSource() else {
            return .unknown
        }
        let source = unmanaged.takeRetainedValue()
        return InputSourceState(
            identifier: stringProperty(source, key: kTISPropertyInputSourceID) ?? "unknown",
            modeIdentifier: stringProperty(source, key: kTISPropertyInputModeID) ?? "",
            localizedName: stringProperty(source, key: kTISPropertyLocalizedName) ?? "不明",
            languages: stringArrayProperty(source, key: kTISPropertyInputSourceLanguages)
        )
    }

    private static func stringProperty(_ source: TISInputSource, key: CFString) -> String? {
        guard let pointer = TISGetInputSourceProperty(source, key) else { return nil }
        return Unmanaged<CFString>.fromOpaque(pointer).takeUnretainedValue() as String
    }

    private static func stringArrayProperty(_ source: TISInputSource, key: CFString) -> [String] {
        guard let pointer = TISGetInputSourceProperty(source, key) else { return [] }
        let values = Unmanaged<CFArray>.fromOpaque(pointer).takeUnretainedValue() as NSArray
        return values.compactMap { $0 as? String }
    }
}
