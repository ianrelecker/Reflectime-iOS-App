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

    var wordCount: Int {
        bodyText.split { $0.isWhitespace || $0.isNewline }.filter { !$0.isEmpty }.count
    }

    var markdown: String {
        var lines = [
            "## \(titleText)",
            "*\(createdAt.formatted(date: .complete, time: .shortened))* · \(categoryName)",
            "",
            bodyText
        ]
        if hasLocation {
            lines.append("")
            lines.append("Location: \(String(format: "%.4f", lat)), \(String(format: "%.4f", lon))")
        }
        return lines.joined(separator: "\n")
    }

    var exportText: String {
        markdown
    }
}

struct DayCount: Identifiable, Hashable {
    var id: Date { day }
    let day: Date
    let count: Int
}

struct ReflectionStats {
    let total: Int
    let located: Int
    let streak: Int
    let longestStreak: Int
    let thisWeek: Int
    let wroteToday: Bool
    let averageWords: Int
    let busiestWeekday: String
    let byCategory: [(category: String, count: Int)]
    let heatmap: [DayCount]

    init(reflections: [Reflection], now: Date = Date(), calendar: Calendar = .current) {
        total = reflections.count
        located = reflections.filter(\.hasLocation).count

        let startOfToday = calendar.startOfDay(for: now)
        thisWeek = reflections.filter {
            calendar.dateComponents([.day], from: calendar.startOfDay(for: $0.createdAt), to: startOfToday).day ?? 0 < 7
        }.count

        let days = Set(reflections.map { calendar.startOfDay(for: $0.createdAt) })
        wroteToday = days.contains(startOfToday)

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

        let orderedDays = days.sorted()
        var longest = 0
        var run = 0
        var previousDay: Date?
        for day in orderedDays {
            if let previousDay, calendar.dateComponents([.day], from: previousDay, to: day).day == 1 {
                run += 1
            } else {
                run = 1
            }
            longest = max(longest, run)
            previousDay = day
        }
        longestStreak = longest

        let words = reflections.map(\.wordCount)
        averageWords = words.isEmpty ? 0 : words.reduce(0, +) / words.count

        var weekdayCounts: [Int: Int] = [:]
        for reflection in reflections {
            let weekday = calendar.component(.weekday, from: reflection.createdAt)
            weekdayCounts[weekday, default: 0] += 1
        }
        if let busiest = weekdayCounts.max(by: { $0.value < $1.value })?.key {
            busiestWeekday = calendar.weekdaySymbols[(busiest - 1 + 7) % 7]
        } else {
            busiestWeekday = "—"
        }

        var counts: [String: Int] = [:]
        for reflection in reflections {
            counts[reflection.categoryName, default: 0] += 1
        }
        byCategory = ReflectionCategory.allCases.map { category in
            (category.rawValue, counts[category.rawValue] ?? 0)
        }

        let perDay = Dictionary(grouping: reflections, by: { calendar.startOfDay(for: $0.createdAt) })
            .mapValues(\.count)
        let weeks = 20
        heatmap = (0..<(weeks * 7)).reversed().compactMap { offset in
            guard let day = calendar.date(byAdding: .day, value: -offset, to: startOfToday) else { return nil }
            return DayCount(day: day, count: perDay[day] ?? 0)
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
