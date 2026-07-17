import Combine
import Foundation

final class AppModel: ObservableObject {
    let settings = AppSettings()
    let inputSource = InputSourceMonitor()
    let permission = PermissionManager()
    let loginItem = LoginItemManager()
    let logger = AppLogger()

    @Published private(set) var isEventTapRunning = false
    @Published private(set) var eventTapError: String?

    private lazy var keyboardMonitor = KeyboardMonitor { [weak self] in
        self?.settings.isEnabled ?? false
    }
    private var cancellables = Set<AnyCancellable>()
    private var permissionTimer: Timer?

    init() {
        [
            settings.objectWillChange,
            inputSource.objectWillChange,
            permission.objectWillChange,
            loginItem.objectWillChange,
            logger.objectWillChange
        ].forEach { publisher in
            publisher
                .sink { [weak self] _ in self?.objectWillChange.send() }
                .store(in: &cancellables)
        }

        keyboardMonitor.onStateChange = { [weak self] running, message in
            DispatchQueue.main.async {
                self?.isEventTapRunning = running
                self?.eventTapError = running ? nil : message
                if let message { self?.logger.info(message) }
            }
        }

        settings.$isEnabled
            .removeDuplicates()
            .sink { [weak self] enabled in
                self?.logger.info(enabled ? "変換をONにしました" : "変換をOFFにしました")
            }
            .store(in: &cancellables)

        permissionTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in
            self?.refreshStatus()
        }

        DispatchQueue.main.async { [weak self] in
            self?.startEventTapIfPossible()
        }
    }

    deinit {
        permissionTimer?.invalidate()
        keyboardMonitor.stop()
    }

    func refreshStatus() {
        let wasGranted = permission.isAccessibilityGranted
        permission.refresh()
        inputSource.refresh()
        loginItem.refresh()
        if !wasGranted && permission.isAccessibilityGranted {
            startEventTapIfPossible()
        }
    }

    func requestPermission() {
        permission.requestAccessibility()
        if permission.isAccessibilityGranted {
            startEventTapIfPossible()
        }
    }

    func startEventTapIfPossible() {
        permission.refresh()
        guard permission.isAccessibilityGranted else {
            isEventTapRunning = false
            eventTapError = "アクセシビリティ権限が必要です"
            return
        }
        do {
            try keyboardMonitor.start()
            logger.info("EventTapを開始しました")
        } catch {
            eventTapError = error.localizedDescription
        }
    }
}
