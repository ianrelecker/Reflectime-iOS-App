import CoreData
import SwiftUI

struct NoteAdd: View {
    var initialPrompt: String? = nil

    @Environment(\.managedObjectContext) private var moc
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var dataController: DataController
    @EnvironmentObject private var location: LocationProvider
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Motivations.date, ascending: false)]
    ) private var motivations: FetchedResults<Motivations>

    @AppStorage("showP") private var showPrompts = true
    @AppStorage("sessionMinutes") private var sessionMinutes = 10

    @State private var name = ""
    @State private var bodyText = ""
    @State private var category = ReflectionCategory.general.rawValue
    @State private var includeLocation = true
    @State private var idea = ""
    @State private var saveError: ReflectionStoreError?
    @State private var confirmCancel = false
    @State private var focusMode = false
    @State private var timedSession = false
    @State private var sessionEnd = Date()
    @State private var savePulse = 0
    @FocusState private var focusedField: Field?

    private enum Field {
        case title
        case body
    }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !bodyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var hasDraft: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || !bodyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var wordCount: Int {
        bodyText.split { $0.isWhitespace || $0.isNewline }.filter { !$0.isEmpty }.count
    }

    var body: some View {
        Form {
            if showPrompts && !focusMode {
                Section("Prompt") {
                    Text(idea.isEmpty ? "Shuffle for a prompt." : idea)
                        .fontWeight(.light)
                    Button("Shuffle prompt", systemImage: "shuffle") {
                        idea = nextPrompt()
                    }
                    NavigationLink("Customize prompts") {
                        PromptView()
                    }
                }
            }

            Section("Reflection") {
                TextField("Title", text: $name)
                    .focused($focusedField, equals: .title)
                TextEditor(text: $bodyText)
                    .frame(minHeight: focusMode ? 280 : 160)
                    .focused($focusedField, equals: .body)
                    .accessibilityLabel("Your thoughts")
                HStack {
                    Text("\(wordCount) word\(wordCount == 1 ? "" : "s")")
                    Spacer()
                    if timedSession {
                        sessionLabel
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            if !focusMode {
                Section("Details") {
                    Picker("Category", selection: $category) {
                        ForEach(ReflectionCategory.allCases) { item in
                            Label(item.rawValue, systemImage: item.symbolName)
                                .tag(item.rawValue)
                        }
                    }

                    if location.isAuthorized {
                        Toggle("Include my location", isOn: $includeLocation)
                    } else {
                        Text("Turn on Location in Settings if you want to remember where this was written.")
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Focus") {
                    Toggle("Timed writing session", isOn: $timedSession)
                    if timedSession {
                        Picker("Length", selection: $sessionMinutes) {
                            Text("5 min").tag(5)
                            Text("10 min").tag(10)
                            Text("15 min").tag(15)
                            Text("25 min").tag(25)
                        }
                        .pickerStyle(.segmented)
                    }
                    Toggle("Hide extra chrome", isOn: $focusMode)
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle("New Reflection")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", role: .cancel) {
                    if hasDraft {
                        confirmCancel = true
                    } else {
                        dismiss()
                    }
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    save()
                }
                .disabled(!canSave)
            }
        }
        .onAppear {
            if let initialPrompt, !initialPrompt.isEmpty {
                idea = initialPrompt
            } else if idea.isEmpty {
                idea = nextPrompt()
            }
            if location.isAuthorized {
                location.refresh()
            }
            focusedField = .title
        }
        .onChange(of: timedSession) { _, enabled in
            if enabled {
                sessionEnd = Date().addingTimeInterval(TimeInterval(sessionMinutes * 60))
            }
        }
        .onChange(of: sessionMinutes) { _, minutes in
            if timedSession {
                sessionEnd = Date().addingTimeInterval(TimeInterval(minutes * 60))
            }
        }
        .confirmationDialog("Discard this reflection?", isPresented: $confirmCancel, titleVisibility: .visible) {
            Button("Discard", role: .destructive) { dismiss() }
            Button("Keep writing", role: .cancel) {}
        }
        .sensoryFeedback(.success, trigger: savePulse)
        .reflectimeErrorAlert($saveError)
    }

    @ViewBuilder
    private var sessionLabel: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let remaining = max(0, sessionEnd.timeIntervalSince(context.date))
            let minutes = Int(remaining) / 60
            let seconds = Int(remaining) % 60
            Text(remaining == 0 ? "Session done" : String(format: "%d:%02d left", minutes, seconds))
                .monospacedDigit()
                .foregroundStyle(remaining == 0 ? .orange : .secondary)
        }
    }

    private func nextPrompt() -> String {
        let items = motivations.compactMap { $0.item?.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        if let random = items.randomElement() {
            return random
        }
        return ReflectionDefaults.prompts.randomElement() ?? ""
    }

    private func save() {
        let title = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let thought = bodyText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else {
            saveError = .emptyTitle
            return
        }
        guard !thought.isEmpty else {
            saveError = .emptyBody
            return
        }

        let reflection = Reflection(context: moc)
        reflection.id = UUID()
        reflection.name = title
        reflection.note = thought
        reflection.cata = category
        reflection.date = Date()
        if includeLocation, location.isAuthorized {
            let coordinate = location.coordinate()
            reflection.lat = coordinate.0
            reflection.lon = coordinate.1
        } else {
            reflection.lat = 0
            reflection.lon = 0
        }

        do {
            try dataController.save()
            savePulse += 1
            dismiss()
        } catch let error as ReflectionStoreError {
            saveError = error
        } catch {
            saveError = .saveFailed(error.localizedDescription)
        }
    }
}

#Preview {
    NavigationStack {
        NoteAdd()
    }
    .environment(\.managedObjectContext, DataController(inMemory: true).container.viewContext)
    .environmentObject(DataController(inMemory: true))
    .environmentObject(LocationProvider.shared)
}
