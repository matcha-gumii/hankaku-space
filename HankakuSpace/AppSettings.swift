import Foundation

final class AppSettings: ObservableObject {
    private enum Key {
        static let isEnabled = "isEnabled"
        static let showStatusNotifications = "showStatusNotifications"
    }

    @Published var isEnabled: Bool {
        didSet { defaults.set(isEnabled, forKey: Key.isEnabled) }
    }

    @Published var showStatusNotifications: Bool {
        didSet { defaults.set(showStatusNotifications, forKey: Key.showStatusNotifications) }
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if defaults.object(forKey: Key.isEnabled) == nil {
            defaults.set(true, forKey: Key.isEnabled)
        }
        isEnabled = defaults.bool(forKey: Key.isEnabled)
        showStatusNotifications = defaults.bool(forKey: Key.showStatusNotifications)
    }
}
