import CoreData
import SwiftUI

struct EditView: View {
    let reflection: Reflection

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var dataController: DataController

    @State private var name = ""
    @State private var note = ""
    @State private var category = ReflectionCategory.general.rawValue
    @State private var keepLocation = true
    @State private var saveError: ReflectionStoreError?

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        Form {
            Section("Reflection") {
                TextField("Title", text: $name)
                TextEditor(text: $note)
                    .frame(minHeight: 140)
                    .accessibilityLabel("Your thoughts")
            }
            Section("Details") {
                Picker("Category", selection: $category) {
                    ForEach(ReflectionCategory.allCases) { item in
                        Label(item.rawValue, systemImage: item.symbolName)
                            .tag(item.rawValue)
                    }
                }
                if reflection.hasLocation || keepLocation {
                    Toggle("Keep location on this reflection", isOn: $keepLocation)
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Edit Reflection")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", role: .cancel) { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { save() }
                    .disabled(!canSave)
            }
        }
        .onAppear {
            name = reflection.name ?? ""
            note = reflection.note ?? ""
            category = ReflectionCategory.displayName(for: reflection.cata)
            keepLocation = reflection.hasLocation
        }
        .reflectimeErrorAlert($saveError)
    }

    private func save() {
        let title = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let thought = note.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else {
            saveError = .emptyTitle
            return
        }
        guard !thought.isEmpty else {
            saveError = .emptyBody
            return
        }

        reflection.name = title
        reflection.note = thought
        reflection.cata = category
        if !keepLocation {
            reflection.lat = 0
            reflection.lon = 0
        }

        do {
            try dataController.save()
            dismiss()
        } catch let error as ReflectionStoreError {
            saveError = error
        } catch {
            saveError = .saveFailed(error.localizedDescription)
        }
    }
}
