import CoreData
import SwiftUI

struct PromptView: View {
    @EnvironmentObject private var dataController: DataController
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Motivations.date, ascending: false)],
        animation: .default
    ) private var motivations: FetchedResults<Motivations>

    @State private var draft = ""
    @State private var saveError: ReflectionStoreError?

    var body: some View {
        List {
            Section("New prompt") {
                HStack {
                    TextField("Write a prompt", text: $draft, axis: .vertical)
                    Button {
                        addPrompt()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .accessibilityLabel("Add prompt")
                }
            }
            Section("Prompts") {
                if motivations.isEmpty {
                    Text("No prompts yet. Add one above, or they will be seeded the first time you open the app.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(motivations, id: \.objectID) { prompt in
                        Text(prompt.item ?? "")
                    }
                    .onDelete(perform: delete)
                }
            }
        }
        .navigationTitle("Prompts")
        .toolbar {
            EditButton()
        }
        .reflectimeErrorAlert($saveError)
    }

    private func addPrompt() {
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        let item = Motivations(context: dataController.container.viewContext)
        item.item = text
        item.date = Date()
        draft = ""
        do {
            try dataController.save()
        } catch let error as ReflectionStoreError {
            dataController.container.viewContext.delete(item)
            saveError = error
        } catch {
            dataController.container.viewContext.delete(item)
            saveError = .saveFailed(error.localizedDescription)
        }
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            dataController.container.viewContext.delete(motivations[index])
        }
        do {
            try dataController.save()
        } catch let error as ReflectionStoreError {
            saveError = error
        } catch {
            saveError = .saveFailed(error.localizedDescription)
        }
    }
}

#Preview {
    NavigationStack {
        PromptView()
    }
    .environmentObject(DataController(inMemory: true))
    .environment(\.managedObjectContext, DataController(inMemory: true).container.viewContext)
}
