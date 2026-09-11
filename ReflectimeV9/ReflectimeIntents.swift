import AppIntents
import Foundation

struct LogReflectionIntent: AppIntent {
    static var title: LocalizedStringResource = "Log a reflection"
    static var description = IntentDescription("Opens Reflectime to write a new journal entry.")
    static var openAppWhenRun = true

    @Parameter(title: "Prompt")
    var prompt: String?

    func perform() async throws -> some IntentResult {
        await MainActor.run {
            NotificationCenter.default.post(name: ReflectimeRouter.compose, object: prompt)
        }
        return .result()
    }
}

struct OpenTodayIntent: AppIntent {
    static var title: LocalizedStringResource = "Open today’s reflections"
    static var description = IntentDescription("Opens Reflectime to today’s journal.")
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        await MainActor.run {
            NotificationCenter.default.post(name: ReflectimeRouter.search, object: nil)
        }
        return .result()
    }
}

struct ReflectionEntity: AppEntity {
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Reflection")
    static var defaultQuery = ReflectionEntityQuery()

    var id: UUID
    var title: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(title)")
    }
}

struct ReflectionEntityQuery: EntityQuery {
    func entities(for identifiers: [UUID]) async throws -> [ReflectionEntity] {
        []
    }

    func suggestedEntities() async throws -> [ReflectionEntity] {
        []
    }
}

struct ReflectimeShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: LogReflectionIntent(),
            phrases: [
                "Log a reflection in \(.applicationName)",
                "Write in \(.applicationName)",
                "Start a journal in \(.applicationName)"
            ],
            shortTitle: "New entry",
            systemImageName: "square.and.pencil"
        )
        AppShortcut(
            intent: OpenTodayIntent(),
            phrases: [
                "Open \(.applicationName)",
                "Show my journal in \(.applicationName)"
            ],
            shortTitle: "Open journal",
            systemImageName: "book.pages"
        )
    }
}
