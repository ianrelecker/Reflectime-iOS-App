import SwiftUI

enum AppTab: Hashable {
    case journal
    case reflect
    case map
    case settings
    case search
}

struct TabsView: View {
    @EnvironmentObject private var dataController: DataController
    @State private var selectedTab: AppTab = .journal
    @State private var showComposer = false
    @State private var composerPrompt: String?
    @AppStorage("showIntro") private var showIntro = true

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Journal", systemImage: "book.pages", value: .journal) {
                NavigationStack {
                    ContentView(onCompose: { presentComposer() })
                }
            }
            Tab("Reflect", systemImage: "sparkles", value: .reflect) {
                NavigationStack {
                    CalendarView(onCompose: { presentComposer() })
                }
            }
            Tab("Map", systemImage: "map", value: .map) {
                NavigationStack {
                    MapViewAll()
                }
            }
            Tab("Settings", systemImage: "gearshape", value: .settings) {
                NavigationStack {
                    SettingsView()
                }
            }
            Tab("Search", systemImage: "magnifyingglass", value: .search, role: .search) {
                NavigationStack {
                    SearchView()
                }
            }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
        .tabViewStyle(.sidebarAdaptable)
        .sheet(isPresented: $showComposer, onDismiss: { composerPrompt = nil }) {
            NavigationStack {
                NoteAdd(initialPrompt: composerPrompt)
            }
            .presentationDetents([.large])
        }
        .sheet(isPresented: $showIntro) {
            NavigationStack {
                IntroView()
            }
            .interactiveDismissDisabled(true)
            .presentationDetents([.large])
        }
        .onReceive(NotificationCenter.default.publisher(for: ReflectimeRouter.compose)) { notification in
            composerPrompt = notification.object as? String
            showComposer = true
            selectedTab = .journal
        }
        .onReceive(NotificationCenter.default.publisher(for: ReflectimeRouter.search)) { _ in
            selectedTab = .search
        }
        .reflectimeErrorAlert($dataController.storeError)
    }

    private func presentComposer(prompt: String? = nil) {
        composerPrompt = prompt
        showComposer = true
    }
}

#Preview {
    TabsView()
        .environment(\.managedObjectContext, DataController(inMemory: true).container.viewContext)
        .environmentObject(DataController(inMemory: true))
        .environmentObject(LocationProvider.shared)
}
