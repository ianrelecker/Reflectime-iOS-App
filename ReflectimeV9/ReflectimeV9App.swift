import SwiftUI
import TipKit
import UserNotifications

@main
struct ReflectimeV9App: App {
    @StateObject private var dataController = DataController()
    @Environment(\.scenePhase) private var scenePhase

    init() {
        try? Tips.configure([
            .displayFrequency(.daily)
        ])
    }

    var body: some Scene {
        WindowGroup {
            TabsView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(dataController)
                .environmentObject(LocationProvider.shared)
                .onAppear {
                    clearBadge()
                }
                .onChange(of: scenePhase) { _, phase in
                    if phase == .active {
                        clearBadge()
                        try? dataController.save()
                    }
                }
                .onOpenURL { url in
                    handle(url)
                }
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Reflection") {
                    NotificationCenter.default.post(name: ReflectimeRouter.compose, object: nil)
                }
                .keyboardShortcut("n", modifiers: .command)
            }
            CommandGroup(after: .newItem) {
                Button("Search Reflections") {
                    NotificationCenter.default.post(name: ReflectimeRouter.search, object: nil)
                }
                .keyboardShortcut("f", modifiers: .command)
            }
        }
    }

    private func clearBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0)
    }

    private func handle(_ url: URL) {
        guard url.scheme == "reflectime" else { return }
        if url.host == "new" || url.path == "/new" {
            NotificationCenter.default.post(name: ReflectimeRouter.compose, object: nil)
        } else if url.host == "search" {
            NotificationCenter.default.post(name: ReflectimeRouter.search, object: nil)
        }
    }
}
