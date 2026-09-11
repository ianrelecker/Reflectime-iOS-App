import SwiftUI
import UserNotifications

@main
struct ReflectimeV9App: App {
    @StateObject private var dataController = DataController()
    @Environment(\.scenePhase) private var scenePhase

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
        }
    }

    private func clearBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0)
    }
}
