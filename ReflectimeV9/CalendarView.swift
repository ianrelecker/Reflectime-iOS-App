import Charts
import CoreData
import SwiftUI
import TipKit

struct CalendarView: View {
    var onCompose: (String?) -> Void = { _ in }

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Reflection.date, ascending: false)],
        animation: .default
    ) private var reflections: FetchedResults<Reflection>

    @State private var selectedCategory: ReflectionCategory?
    @State private var selectedDay = Date()
    @State private var filterByDay = false

    private var items: [Reflection] {
        Array(reflections).filter { reflection in
            if let selectedCategory, !ReflectionCategory.matches(reflection.cata, category: selectedCategory) {
                return false
            }
            if filterByDay {
                return Calendar.current.isDate(reflection.createdAt, inSameDayAs: selectedDay)
            }
            return true
        }
    }

    var body: some View {
        let stats = ReflectionStats(reflections: Array(reflections))
        Group {
            if reflections.count < 3 {
                opaquesortview(onCompose: { onCompose(nil) })
            } else {
                List {
                    Section("This stretch") {
                        InsightStrip(stats: stats)
                        StreakHeatmap(days: stats.heatmap)
                            .listRowInsets(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                        if stats.byCategory.contains(where: { $0.count > 0 }) {
                            Chart(stats.byCategory.filter { $0.count > 0 }, id: \.category) { item in
                                BarMark(
                                    x: .value("Category", item.category),
                                    y: .value("Count", item.count)
                                )
                                .foregroundStyle(by: .value("Category", item.category))
                            }
                            .chartLegend(.hidden)
                            .frame(height: 160)
                            .accessibilityLabel("Reflections by category")
                        }
                        LabeledContent("Longest streak", value: "\(stats.longestStreak) day\(stats.longestStreak == 1 ? "" : "s")")
                        LabeledContent("Average length", value: "\(stats.averageWords) words")
                        LabeledContent("Busiest day", value: stats.busiestWeekday)
                    }

                    Section("Look back") {
                        Toggle("Filter by day", isOn: $filterByDay)
                        if filterByDay {
                            DatePicker("Day", selection: $selectedDay, displayedComponents: .date)
                        }
                        Picker("Category", selection: $selectedCategory) {
                            Text("All").tag(Optional<ReflectionCategory>.none)
                            ForEach(ReflectionCategory.allCases) { category in
                                Text(category.rawValue).tag(Optional(category))
                            }
                        }
                    }

                    Section(items.isEmpty ? "No matching reflections" : "Reflections") {
                        if items.isEmpty {
                            ContentUnavailableView("No matching reflections", systemImage: "line.3.horizontal.decrease.circle", description: Text("Try another day or category."))
                        } else {
                            ForEach(items, id: \.objectID) { reflection in
                                NavigationLink {
                                    NoteDetail(reflection: reflection)
                                } label: {
                                    VStack(alignment: .leading, spacing: 6) {
                                        HStack {
                                            Text(reflection.titleText)
                                                .font(.headline)
                                            Spacer()
                                            if reflection.hasLocation {
                                                Image(systemName: "location.fill")
                                                    .font(.caption)
                                                    .foregroundStyle(.tertiary)
                                                    .accessibilityLabel("Includes location")
                                            }
                                        }
                                        Text(reflection.createdAt.formatted(date: .long, time: .omitted))
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                        Text(reflection.bodyText)
                                            .font(.body)
                                            .lineLimit(6)
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Reflect")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("New Reflection", systemImage: "plus") {
                    onCompose(nil)
                }
            }
        }
        .scrollEdgeEffectStyle(.soft, for: .top)
        .popoverTip(InsightsTip())
    }
}

private struct InsightStrip: View {
    let stats: ReflectionStats

    var body: some View {
        HStack(spacing: 12) {
            InsightChip(title: "Streak", value: "\(stats.streak)d", symbol: "flame")
            InsightChip(title: "This week", value: "\(stats.thisWeek)", symbol: "calendar")
            InsightChip(title: "Located", value: "\(stats.located)", symbol: "location")
        }
        .listRowInsets(EdgeInsets(top: 8, leading: 4, bottom: 8, trailing: 4))
        .listRowBackground(Color.clear)
    }
}

private struct InsightChip: View {
    let title: String
    let value: String
    let symbol: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(title, systemImage: symbol)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title2.weight(.semibold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct StreakHeatmap: View {
    let days: [DayCount]

    private var cells: [DayCount?] {
        guard let first = days.first else { return [] }
        let weekday = Calendar.current.component(.weekday, from: first.day)
        let leading = max(0, weekday - 1)
        return Array(repeating: nil, count: leading) + days.map { Optional($0) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Last 20 weeks")
                .font(.caption)
                .foregroundStyle(.secondary)
            LazyHGrid(
                rows: Array(repeating: GridItem(.fixed(10), spacing: 3), count: 7),
                spacing: 3
            ) {
                ForEach(Array(cells.enumerated()), id: \.offset) { _, day in
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .fill(color(for: day?.count ?? 0))
                        .frame(width: 10, height: 10)
                        .opacity(day == nil ? 0 : 1)
                        .accessibilityLabel(day.map {
                            "\($0.day.formatted(date: .abbreviated, time: .omitted)), \($0.count) reflection\($0.count == 1 ? "" : "s")"
                        } ?? "Empty")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .contain)
    }

    private func color(for count: Int) -> Color {
        switch count {
        case 0: return Color.secondary.opacity(0.15)
        case 1: return Color.accentColor.opacity(0.35)
        case 2: return Color.accentColor.opacity(0.6)
        default: return Color.accentColor
        }
    }
}

#Preview {
    NavigationStack {
        CalendarView()
    }
    .environment(\.managedObjectContext, DataController(inMemory: true).container.viewContext)
}
