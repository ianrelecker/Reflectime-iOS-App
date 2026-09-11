import SwiftUI
import TipKit
import UserNotifications

final class ReflectimeNotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = ReflectimeNotificationDelegate()

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound, .badge]
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        ReflectimeRouter.requestCompose()
    }
}

@main
struct ReflectimeV9App: App {
    @StateObject private var dataController = DataController()
    @Environment(\.scenePhase) private var scenePhase

    init() {
        UNUserNotificationCenter.current().delegate = ReflectimeNotificationDelegate.shared
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
                    }
                }
                .onOpenURL { url in
                    handle(url)
                }
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Reflection") {
                    ReflectimeRouter.requestCompose()
                }
                .keyboardShortcut("n", modifiers: .command)
            }
            CommandGroup(after: .newItem) {
                Button("Search Reflections") {
                    ReflectimeRouter.requestSearch()
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
            ReflectimeRouter.requestCompose()
        } else if url.host == "search" {
            ReflectimeRouter.requestSearch()
        } else {
            ReflectimeRouter.requestJournal()
        }
    }
}
