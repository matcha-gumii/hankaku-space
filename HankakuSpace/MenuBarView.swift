import AppKit
import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        Toggle("変換を有効にする", isOn: Binding(
            get: { model.settings.isEnabled },
            set: { model.settings.isEnabled = $0 }
        ))

        Divider()

        Label(model.inputSource.current.localizedName, systemImage: "keyboard")
        Label(
            model.inputSource.current.isJapanese ? "日本語入力" : "英語・英数入力",
            systemImage: model.inputSource.current.isJapanese ? "character.ja" : "character"
        )

        if model.permission.isAccessibilityGranted {
            Label("アクセシビリティ: 許可済み", systemImage: "checkmark.shield")
        } else {
            Button("アクセシビリティ権限を許可…") {
                model.requestPermission()
            }
        }

        if let error = model.eventTapError {
            Text(error)
        } else {
            Label(
                model.isEventTapRunning ? "監視中" : "停止中",
                systemImage: model.isEventTapRunning ? "waveform" : "pause.circle"
            )
        }

        Divider()

        Toggle("ログイン時に起動", isOn: Binding(
            get: { model.loginItem.isEnabled },
            set: { model.loginItem.setEnabled($0) }
        ))

        SettingsLink {
            Text("設定…")
        }

        Divider()

        Text("Hankaku Space 1.0.0")
            .foregroundStyle(.secondary)

        Button("終了") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q")
    }
}
