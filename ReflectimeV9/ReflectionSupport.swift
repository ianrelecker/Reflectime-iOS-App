import CoreData
import CoreLocation
import Foundation
import SwiftUI

enum ReflectionStoreError: LocalizedError, Equatable {
    case storeLoadFailed(String)
    case saveFailed(String)
    case emptyTitle
    case emptyBody
    case intelligenceUnavailable
    case iCloudUnavailable

    var errorDescription: String? {
        switch self {
        case .storeLoadFailed:
            return "Couldn’t open your journal"
        case .saveFailed:
            return "Couldn’t save this reflection"
        case .emptyTitle:
            return "Add a title"
        case .emptyBody:
            return "Write a thought first"
        case .intelligenceUnavailable:
            return "On-device insights aren’t available"
        case .iCloudUnavailable:
            return "iCloud is unavailable"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .storeLoadFailed(let detail):
            return detail
        case .saveFailed(let detail):
            return detail
        case .emptyTitle:
            return "Every reflection needs a title before it can be saved."
        case .emptyBody:
            return "Add a few sentences so there’s something to come back to."
        case .intelligenceUnavailable:
            return "Apple Intelligence needs a supported device and the on-device model downloaded."
        case .iCloudUnavailable:
            return "Sign in to iCloud in Settings, then try again."
        }
    }
}

enum ReflectionCategory: String, CaseIterable, Identifiable, Hashable {
    case general = "General"
    case personal = "Personal"
    case work = "Work"
    case feelings = "Feelings"
    case wishes = "Wishes"
    case interests = "Interests"
    case love = "Love"
    case activity = "Activity"

    var id: String { rawValue }

    var symbolName: String {
        switch self {
        case .general: return "square.grid.2x2"
        case .personal: return "person"
        case .work: return "briefcase"
        case .feelings: return "heart"
        case .wishes: return "sparkle"
        case .interests: return "star"
        case .love: return "heart.circle"
        case .activity: return "figure.walk"
        }
    }

    static func displayName(for stored: String?) -> String {
        let value = (stored ?? rawGeneral).trimmingCharacters(in: .whitespacesAndNewlines)
        if value.isEmpty { return rawGeneral }
        if value == legacyInterests { return interests.rawValue }
        return value
    }

    static func matches(_ stored: String?, category: ReflectionCategory) -> Bool {
        let displayed = displayName(for: stored)
        if category == .interests {
            return displayed == category.rawValue || stored == legacyInterests
        }
        return displayed == category.rawValue
    }

    private static let rawGeneral = ReflectionCategory.general.rawValue
    private static let legacyInterests = "Intrests"
}

enum ReflectionDefaults {
    static let prompts: [String] = [
        "Write down what you are thinking about now. It could be issues you are having, something you want, or goals you are working toward.\n\nWrite it down, then reflect on it.",
        "Try separating your thoughts into different sections. If your main thought is a difficulty, what part of your life is this in?",
        "Be honest with yourself. If something isn’t going right, reflect on that. What is the issue? How would someone else deal with this?",
        "What are you celebrating today? What was something you learned, got better at, or practiced?",
        "What is a long term project of yours?",
        "Who are you comparing yourself to? Is this healthy?",
        "Why are you amazing?",
        "What is the best thing that has happened today?",
        "What did you just complete?",
        "What are you looking forward to?",
        "How can you make this next week better than the last?",
        "What do you want more of?",
        "You are the best.",
        "How was your day?",
        "Reflect on the most impactful thing you did.",
        "Reflect on what made you upset.",
        "Reflect on what made you happy.",
        "Reflect on what you are proud of."
    ]
}

enum ReflectimeRouter {
    static let compose = Notification.Name("ReflectimeCompose")
    static let search = Notification.Name("ReflectimeSearch")
}

extension Reflection {
    var titleText: String {
        let trimmed = name?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmed.isEmpty ? "Untitled" : trimmed
    }

    var bodyText: String {
        note?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }

    var categoryName: String {
        ReflectionCategory.displayName(for: cata)
    }

    var hasLocation: Bool {
        abs(lat) > 0.0001 || abs(lon) > 0.0001
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    var createdAt: Date {
        date ?? Date()
    }

    var exportText: String {
        var lines = [
            titleText,
            "",
            bodyText,
            "",
            createdAt.formatted(date: .complete, time: .shortened),
            "Category: \(categoryName)"
        ]
        if hasLocation {
            lines.append("Location: \(lat), \(lon)")
        }
        return lines.joined(separator: "\n")
    }
}

struct ReflectionStats {
    let total: Int
    let located: Int
    let streak: Int
    let thisWeek: Int
    let byCategory: [(category: String, count: Int)]

    init(reflections: [Reflection]) {
        total = reflections.count
        located = reflections.filter(\.hasLocation).count

        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        thisWeek = reflections.filter {
            calendar.dateComponents([.day], from: calendar.startOfDay(for: $0.createdAt), to: startOfToday).day ?? 0 < 7
        }.count

        let days = Set(reflections.map { calendar.startOfDay(for: $0.createdAt) })
        var streak = 0
        var cursor = startOfToday
        if !days.contains(cursor) {
            cursor = calendar.date(byAdding: .day, value: -1, to: cursor) ?? cursor
        }
        while days.contains(cursor) {
            streak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = previous
        }
        self.streak = streak

        var counts: [String: Int] = [:]
        for reflection in reflections {
            counts[reflection.categoryName, default: 0] += 1
        }
        byCategory = ReflectionCategory.allCases.map { category in
            (category.rawValue, counts[category.rawValue] ?? 0)
        }
    }
}

extension View {
    func reflectimeErrorAlert(_ error: Binding<ReflectionStoreError?>) -> some View {
        alert(
            error.wrappedValue?.errorDescription ?? "Something went wrong",
            isPresented: Binding(
                get: { error.wrappedValue != nil },
                set: { if !$0 { error.wrappedValue = nil } }
            )
        ) {
            Button("OK", role: .cancel) { error.wrappedValue = nil }
        } message: {
            Text(error.wrappedValue?.recoverySuggestion ?? "")
        }
    }
}
