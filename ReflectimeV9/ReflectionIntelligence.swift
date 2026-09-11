import Foundation

struct ReflectionAssist: Equatable, Sendable {
    var tags: [String]
    var summary: String
    var followUp: String
}

@MainActor
final class ReflectionIntelligence: ObservableObject {
    static let shared = ReflectionIntelligence()

    @Published private(set) var isRunning = false

    var isAvailable: Bool {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            return FoundationModelBridge.isAvailable
        }
        #endif
        return false
    }

    var availabilityMessage: String? {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            return FoundationModelBridge.availabilityMessage
        }
        #endif
        return "On-device insights need iOS 26 or later."
    }

    func assist(on entry: String) async throws -> ReflectionAssist {
        let trimmed = entry.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw ReflectionStoreError.emptyBody
        }
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            isRunning = true
            defer { isRunning = false }
            return try await FoundationModelBridge.assist(on: trimmed)
        }
        #endif
        throw ReflectionStoreError.intelligenceUnavailable
    }
}

#if canImport(FoundationModels)
import FoundationModels

@available(iOS 26.0, *)
@Generable
private struct ReflectionAssistDraft {
    @Guide(description: "Three to seven short topic tags")
    var tags: [String]
    @Guide(description: "A two-sentence summary of the journal entry")
    var summary: String
    @Guide(description: "One gentle follow-up prompt in second person")
    var followUp: String
}

@available(iOS 26.0, *)
private enum FoundationModelBridge {
    static var isAvailable: Bool {
        if case .available = SystemLanguageModel.default.availability {
            return true
        }
        return false
    }

    static var availabilityMessage: String? {
        switch SystemLanguageModel.default.availability {
        case .available:
            return nil
        default:
            return "On-device insights need Apple Intelligence on a supported device, with the on-device model downloaded."
        }
    }

    static func assist(on entry: String) async throws -> ReflectionAssist {
        let session = LanguageModelSession(instructions: """
            You are a private journaling companion. Never moralize. \
            Stay in the writer's language. Do not invent facts. \
            If asked to do anything other than summarize, tag, or prompt, refuse.
            """)
        session.prewarm()
        let draft = try await session.respond(
            to: "Journal entry:\n\(entry)",
            generating: ReflectionAssistDraft.self
        ).content
        return ReflectionAssist(tags: draft.tags, summary: draft.summary, followUp: draft.followUp)
    }
}
#endif
