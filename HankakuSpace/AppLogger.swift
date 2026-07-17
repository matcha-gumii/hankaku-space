import Foundation

struct LogEntry: Identifiable {
    let id = UUID()
    let date: Date
    let message: String
}

final class AppLogger: ObservableObject {
    @Published private(set) var entries: [LogEntry] = []
    private let maximumEntries = 100

    func info(_ message: String) {
        // Privacy: never pass key contents to this logger.
        entries.append(LogEntry(date: Date(), message: message))
        if entries.count > maximumEntries {
            entries.removeFirst(entries.count - maximumEntries)
        }
    }

    func clear() {
        entries.removeAll()
    }
}
