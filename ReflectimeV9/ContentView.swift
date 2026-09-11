import CoreData
import SwiftUI
import TipKit

struct ContentView: View {
    var onCompose: (String?) -> Void = { _ in }

    @Environment(\.managedObjectContext) private var moc
    @EnvironmentObject private var dataController: DataController
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Reflection.date, ascending: false)],
        animation: .default
    ) private var reflections: FetchedResults<Reflection>

    @State private var saveError: ReflectionStoreError?
    @State private var pendingDelete: Reflection?
    @State private var deletePulse = 0

    private var grouped: [(String, [Reflection])] {
        let groups = Dictionary(grouping: Array(reflections), by: \.categoryName)
        return ReflectionCategory.allCases.compactMap { category in
            let items = groups[category.rawValue] ?? []
            return items.isEmpty ? nil : (category.rawValue, items)
        }
    }

    var body: some View {
        Group {
            if reflections.isEmpty {
                ContentUnavailableView {
                    Label("No reflections yet", systemImage: "book.closed")
                } description: {
                    Text("Write your first one. It’s private, on this device, and synced with iCloud when you’re signed in.")
                } actions: {
                    Button("New Reflection", systemImage: "plus") {
                        onCompose(nil)
                    }
                    .buttonStyle(.glassProminent)
                }
            } else {
                VStack(alignment: .leading, spacing: 0) {
                    TodayPromptCard(
                        wroteToday: reflections.contains { Calendar.current.isDateInToday($0.createdAt) },
                        prompt: todayPrompt,
                        onWrite: { onCompose(todayPrompt) }
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 12)
                    List {
                        ForEach(grouped, id: \.0) { category, items in
                            Section(category) {
                                ForEach(items, id: \.objectID) { reflection in
                                    NavigationLink {
                                        NoteDetail(reflection: reflection)
                                    } label: {
                                        ReflectionRow(reflection: reflection)
                                    }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button("Delete", systemImage: "trash", role: .destructive) {
                                            pendingDelete = reflection
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("New Reflection", systemImage: "plus") {
                    onCompose(nil)
                }
            }
            ToolbarSpacer(.fixed)
            ToolbarItem(placement: .primaryAction) {
                if !reflections.isEmpty {
                    Text("\(reflections.count)")
                        .font(.subheadline.monospacedDigit())
                        .foregroundStyle(.secondary)
                        .accessibilityLabel("\(reflections.count) reflections")
                }
            }
        }
        .confirmationDialog(
            "Delete this reflection?",
            isPresented: Binding(
                get: { pendingDelete != nil },
                set: { if !$0 { pendingDelete = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                if let pendingDelete {
                    delete(pendingDelete)
                }
            }
            Button("Cancel", role: .cancel) {
                pendingDelete = nil
            }
        } message: {
            Text("This can’t be undone.")
        }
        .reflectimeErrorAlert($saveError)
        .scrollEdgeEffectStyle(.soft, for: .top)
        .sensoryFeedback(.warning, trigger: deletePulse)
        .popoverTip(ComposeTip())
    }

    private var todayPrompt: String {
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        let prompts = ReflectionDefaults.prompts
        return prompts[day % prompts.count]
    }

    private func delete(_ reflection: Reflection) {
        do {
            try dataController.delete(reflection)
        } catch let error as ReflectionStoreError {
            saveError = error
        } catch {
            saveError = .saveFailed(error.localizedDescription)
        }
        deletePulse += 1
        pendingDelete = nil
    }
}

private struct TodayPromptCard: View {
    let wroteToday: Bool
    let prompt: String
    let onWrite: () -> Void

    var body: some View {
        Button(action: onWrite) {
            VStack(alignment: .leading, spacing: 6) {
                Text(wroteToday ? "You already wrote today" : "Today’s prompt")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(prompt)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.plain)
        .accessibilityHint("Opens a new reflection with this prompt")
    }
}

struct ReflectionRow: View {
    let reflection: Reflection

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(spacing: 2) {
                Text(reflection.createdAt.formatted(.dateTime.month(.abbreviated)))
                    .font(.caption.weight(.medium))
                Text(reflection.createdAt.formatted(.dateTime.day()))
                    .font(.title3.weight(.semibold))
            }
            .foregroundStyle(.tint)
            .frame(width: 48)
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(reflection.titleText)
                    .font(.headline)
                    .lineLimit(1)
                Text(reflection.bodyText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                Text("\(reflection.wordCount) words")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            if reflection.hasLocation {
                Image(systemName: "location.fill")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .accessibilityLabel("Includes location")
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(reflection.titleText), \(reflection.categoryName), \(reflection.createdAt.formatted(date: .abbreviated, time: .omitted))")
    }
}

struct NoteDetail: View {
    let reflection: Reflection
    @State private var showEdit = false
    @ObservedObject private var intelligence = ReflectionIntelligence.shared
    @State private var assist: ReflectionAssist?
    @State private var assistError: ReflectionStoreError?

    var body: some View {
        List {
            Section("Title") {
                Text(reflection.titleText)
                    .font(.title2.weight(.semibold))
                    .textSelection(.enabled)
            }
            Section("Your thought") {
                Text(reflection.bodyText.isEmpty ? "No text in this reflection." : reflection.bodyText)
                    .font(.body)
                    .textSelection(.enabled)
            }
            Section("Details") {
                LabeledContent("Written") {
                    Text(reflection.createdAt.formatted(date: .complete, time: .shortened))
                }
                LabeledContent("Category") {
                    Text(reflection.categoryName)
                }
            }
            if reflection.hasLocation {
                Section("Where you were") {
                    MapView(place: IdentifiablePlace(id: reflection.id ?? UUID(), lat: reflection.lat, lon: reflection.lon))
                        .listRowInsets(EdgeInsets())
                        .frame(minHeight: 180)
                }
            }
            if intelligence.isAvailable {
                Section("On-device insights") {
                    if let assist {
                        if !assist.tags.isEmpty {
                            Text(assist.tags.joined(separator: " · "))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Text(assist.summary)
                        Text(assist.followUp)
                            .italic()
                    } else {
                        Button {
                            Task { await runAssist() }
                        } label: {
                            if intelligence.isRunning {
                                ProgressView("Reading privately…")
                            } else {
                                Label("Summarize this reflection", systemImage: "sparkles")
                            }
                        }
                        .disabled(intelligence.isRunning)
                    }
                }
            } else if let message = intelligence.availabilityMessage {
                Section("On-device insights") {
                    Text(message)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle(reflection.titleText)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit", systemImage: "pencil") {
                    showEdit = true
                }
            }
            ToolbarSpacer(.fixed)
            ToolbarItem(placement: .primaryAction) {
                ShareLink(item: reflection.exportText)
            }
        }
        .sheet(isPresented: $showEdit) {
            NavigationStack {
                EditView(reflection: reflection)
            }
            .presentationDetents([.medium, .large])
        }
        .reflectimeErrorAlert($assistError)
        .popoverTip(IntelligenceTip())
        .onAppear {
            intelligence.refreshAvailability()
        }
    }

    private func runAssist() async {
        do {
            assist = try await intelligence.assist(on: "\(reflection.titleText)\n\n\(reflection.bodyText)")
        } catch let error as ReflectionStoreError {
            assistError = error
        } catch {
            assistError = .intelligenceUnavailable
        }
    }
}

#Preview {
    NavigationStack {
        ContentView()
    }
    .environment(\.managedObjectContext, DataController(inMemory: true).container.viewContext)
    .environmentObject(DataController(inMemory: true))
}
