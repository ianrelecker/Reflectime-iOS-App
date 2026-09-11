import CoreData
import SwiftUI

struct IntroView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var dataController: DataController
    @EnvironmentObject private var location: LocationProvider
    @AppStorage("showIntro") private var showIntro = true
    @AppStorage("showP") private var showPrompts = true
    @AppStorage("sendNot") private var sendNotifications = true
    @State private var reminderTime = ReflectionNotifier.storedReminderDate()
    @State private var seedError: ReflectionStoreError?

    var body: some View {
        Form {
            Section {
                Text("Hi, I’m Ian.")
                    .font(.title2.weight(.semibold))
                Text("I built Reflectime as a quiet place to look back on your day. Your writing stays on your devices, with iCloud sync when you’re signed in.")
            }

            Section("Location") {
                Text("Location is optional. When you include it, it’s stored with that reflection so you can see where you were.")
                    .foregroundStyle(.secondary)
                Button(location.isAuthorized ? "Location is on" : "Allow location") {
                    location.requestAccess()
                }
                .disabled(location.isAuthorized)
            }

            Section("Reminders") {
                Text("Pick a time with a few spare minutes. You can change this later in Settings.")
                    .foregroundStyle(.secondary)
                DatePicker("Remind me at", selection: $reminderTime, displayedComponents: .hourAndMinute)
                Button("Allow notifications") {
                    ReflectionNotifier.shared.requestPermission()
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Welcome")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Get started") {
                    finish()
                }
                .buttonStyle(.glassProminent)
            }
        }
        .onAppear {
            seedPrompts()
            reminderTime = ReflectionNotifier.storedReminderDate()
        }
        .reflectimeErrorAlert($seedError)
    }

    private func seedPrompts() {
        do {
            try dataController.seedDefaultPromptsIfNeeded()
        } catch let error as ReflectionStoreError {
            seedError = error
        } catch {
            seedError = .saveFailed(error.localizedDescription)
        }
    }

    private func finish() {
        seedPrompts()
        ReflectionNotifier.shared.applySchedule(date: reminderTime, enabled: sendNotifications)
        showIntro = false
        dismiss()
    }
}

#Preview {
    NavigationStack {
        IntroView()
    }
    .environmentObject(DataController(inMemory: true))
    .environmentObject(LocationProvider.shared)
}
