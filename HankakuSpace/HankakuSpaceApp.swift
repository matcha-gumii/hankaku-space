import SwiftUI

@main
struct HankakuSpaceApp: App {
    @StateObject private var model = AppModel()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some Scene {
        MenuBarExtra {
            MenuBarView()
                .environmentObject(model)
        } label: {
            Text(menuBarLabel)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .accessibilityLabel(menuBarAccessibilityLabel)
        }
        .menuBarExtraStyle(.menu)

        Window("Hankaku Space", id: "welcome") {
            WelcomeView(hasCompletedOnboarding: $hasCompletedOnboarding)
                .environmentObject(model)
        }
        .defaultSize(width: 440, height: 350)
        .windowResizability(.contentSize)
        .defaultLaunchBehavior(hasCompletedOnboarding ? .suppressed : .presented)

        Settings {
            SettingsView()
                .environmentObject(model)
        }
    }

    private var menuBarLabel: String {
        if !model.permission.isAccessibilityGranted {
            return "H!"
        }
        return model.settings.isEnabled ? "H" : "H–"
    }

    private var menuBarAccessibilityLabel: String {
        if !model.permission.isAccessibilityGranted {
            return "Hankaku Space、アクセシビリティ権限が必要"
        }
        return model.settings.isEnabled ? "Hankaku Space、有効" : "Hankaku Space、無効"
    }
}
