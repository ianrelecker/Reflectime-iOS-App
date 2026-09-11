import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var location: LocationProvider
    @AppStorage("sendNot") private var sendNotifications = true
    @AppStorage("showP") private var showPrompts = true
    @State private var reminderTime = ReflectionNotifier.storedReminderDate()

    var body: some View {
        Form {
            Section("Daily reminder") {
                DatePicker("Remind me at", selection: $reminderTime, displayedComponents: .hourAndMinute)
                Toggle("Send daily notifications", isOn: $sendNotifications)
            }

            Section("Writing") {
                NavigationLink("Edit your prompts") {
                    PromptView()
                }
                Toggle("Show prompts when writing", isOn: $showPrompts)
            }

            Section("Privacy") {
                LabeledContent("Location") {
                    Text(location.isAuthorized ? "On" : "Off")
                        .foregroundStyle(.secondary)
                }
                Button("Request location access") {
                    location.requestAccess()
                }
                Button("Request notification access") {
                    ReflectionNotifier.shared.requestPermission()
                }
            } footer: {
                Text("Location is only stored with a reflection when you choose to include it. Notifications are a daily nudge to write. If a prompt doesn’t appear, open Settings → Reflectime and grant access there.")
            }

            Section("Support") {
                if let url = URL(string: "https://www.ianrelecker.com/reflectime-app/privacy-policy") {
                    Link("Privacy Policy", destination: url)
                }
                if let url = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/") {
                    Link("EULA", destination: url)
                }
                if let url = URL(string: "https://www.ianrelecker.com/contact") {
                    Link("Contact", destination: url)
                }
            }

            Section("About") {
                LabeledContent("Version", value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "3.0")
                Text("Reflections stay on your devices through iCloud. On-device insights never leave the phone.")
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Settings")
        .onChange(of: reminderTime) { _, newValue in
            ReflectionNotifier.shared.applySchedule(date: newValue, enabled: sendNotifications)
        }
        .onChange(of: sendNotifications) { _, enabled in
            ReflectionNotifier.shared.applySchedule(date: reminderTime, enabled: enabled)
        }
        .onAppear {
            reminderTime = ReflectionNotifier.storedReminderDate()
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .environmentObject(LocationProvider.shared)
}
