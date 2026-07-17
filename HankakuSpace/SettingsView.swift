import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        TabView {
            generalView
                .tabItem { Label("一般", systemImage: "gear") }
            behaviorView
                .tabItem { Label("動作", systemImage: "keyboard") }
            advancedView
                .tabItem { Label("詳細", systemImage: "info.circle") }
        }
        .frame(width: 520, height: 360)
        .padding()
        .onAppear { model.refreshStatus() }
    }

    private var generalView: some View {
        Form {
            Section("権限") {
                LabeledContent("アクセシビリティ") {
                    Text(model.permission.isAccessibilityGranted ? "許可済み" : "未許可")
                }
                if !model.permission.isAccessibilityGranted {
                    HStack {
                        Button("権限を要求") { model.requestPermission() }
                        Button("システム設定を開く") { model.permission.openAccessibilitySettings() }
                    }
                }
            }

            Section("起動") {
                Toggle("ログイン時にHankaku Spaceを起動", isOn: Binding(
                    get: { model.loginItem.isEnabled },
                    set: { model.loginItem.setEnabled($0) }
                ))
                if let error = model.loginItem.lastError {
                    Text(error).foregroundStyle(.red)
                }
            }
        }
        .formStyle(.grouped)
    }

    private var behaviorView: some View {
        Form {
            Section("Space変換") {
                Toggle("日本語入力中にSpaceをShift+Spaceへ変換", isOn: Binding(
                    get: { model.settings.isEnabled },
                    set: { model.settings.isEnabled = $0 }
                ))
                Text("Shift、Command、Option、Control、Fnのいずれかを押している場合は変換しません。")
                    .foregroundStyle(.secondary)
            }

            Section("現在の状態") {
                LabeledContent("入力ソース", value: model.inputSource.current.localizedName)
                LabeledContent("判定", value: model.inputSource.current.isJapanese ? "日本語" : "英語・英数")
                LabeledContent("EventTap", value: model.isEventTapRunning ? "動作中" : "停止中")
            }
        }
        .formStyle(.grouped)
    }

    private var advancedView: some View {
        VStack(alignment: .leading, spacing: 12) {
            GroupBox("入力ソース情報") {
                Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 6) {
                    GridRow { Text("ID"); Text(model.inputSource.current.identifier).textSelection(.enabled) }
                    GridRow { Text("Mode"); Text(model.inputSource.current.modeIdentifier).textSelection(.enabled) }
                    GridRow { Text("Languages"); Text(model.inputSource.current.languages.joined(separator: ", ")) }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(4)
            }

            HStack {
                Text("状態ログ（メモリのみ）")
                Spacer()
                Button("消去") { model.logger.clear() }
            }
            List(model.logger.entries.suffix(30).reversed()) { entry in
                HStack {
                    Text(entry.date, style: .time).monospacedDigit()
                    Text(entry.message)
                }
            }
        }
    }
}

struct WelcomeView: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.dismissWindow) private var dismissWindow
    @Binding var hasCompletedOnboarding: Bool

    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: statusIconName)
                .font(.system(size: 52))
                .foregroundStyle(statusColor)

            Text(statusTitle)
                .font(.title2.bold())

            Text(statusMessage)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Toggle("日本語入力中のSpaceを半角にする", isOn: Binding(
                get: { model.settings.isEnabled },
                set: { model.settings.isEnabled = $0 }
            ))
            .toggleStyle(.switch)

            if !model.permission.isAccessibilityGranted {
                HStack {
                    Button("権限を要求") { model.requestPermission() }
                    Button("システム設定を開く") { model.permission.openAccessibilitySettings() }
                }
            }

            Text("以後はメニューバーの「H」から切り替えられます。")
                .font(.callout)
                .foregroundStyle(.secondary)

            Button("はじめる") {
                hasCompletedOnboarding = true
                dismissWindow(id: "welcome")
            }
            .buttonStyle(.borderedProminent)

            Text("Hankaku Space 1.0.0")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(28)
        .onAppear { model.refreshStatus() }
    }

    private var statusIconName: String {
        if !model.permission.isAccessibilityGranted { return "exclamationmark.triangle.fill" }
        return model.settings.isEnabled ? "checkmark.circle.fill" : "pause.circle.fill"
    }

    private var statusColor: Color {
        if !model.permission.isAccessibilityGranted { return .orange }
        return model.settings.isEnabled ? .green : .secondary
    }

    private var statusTitle: String {
        if !model.permission.isAccessibilityGranted { return "権限の設定が必要です" }
        return model.settings.isEnabled ? "Hankaku Spaceは有効です" : "Hankaku Spaceは無効です"
    }

    private var statusMessage: String {
        if !model.permission.isAccessibilityGranted {
            return "Spaceキーを変換するには、アクセシビリティ権限を許可してください。"
        }
        return model.settings.isEnabled
            ? "日本語入力中のSpaceを半角スペースに変換しています。"
            : "下のスイッチをONにすると変換を開始します。"
    }
}
