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
                    ContentView(onCompose: { presentComposer(prompt: $0) })
                }
            }
            Tab("Reflect", systemImage: "sparkles", value: .reflect) {
                NavigationStack {
                    CalendarView(onCompose: { presentComposer(prompt: $0) })
                }
            }
            Tab("Map", systemImage: "map", value: .map) {
                NavigationStack {
                    MapViewAll(onCompose: { presentComposer() })
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
        .onAppear {
            drainPendingCompose()
        }
        .onChange(of: showIntro) { _, showing in
            if !showing {
                drainPendingCompose()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: ReflectimeRouter.compose)) { notification in
            guard !showIntro else { return }
            presentComposer(prompt: notification.object as? String)
            selectedTab = .journal
        }
        .onReceive(NotificationCenter.default.publisher(for: ReflectimeRouter.search)) { _ in
            selectedTab = .search
        }
        .onReceive(NotificationCenter.default.publisher(for: ReflectimeRouter.journal)) { _ in
            selectedTab = .journal
        }
        .reflectimeErrorAlert($dataController.storeError)
    }

    private func presentComposer(prompt: String? = nil) {
        _ = ReflectimeRouter.consumePendingCompose()
        composerPrompt = prompt
        showComposer = true
    }

    private func drainPendingCompose() {
        guard !showIntro else { return }
        let pending = ReflectimeRouter.consumePendingCompose()
        guard pending.pending else { return }
        composerPrompt = pending.prompt
        showComposer = true
        selectedTab = .journal
    }
}

#Preview {
    TabsView()
        .environment(\.managedObjectContext, DataController(inMemory: true).container.viewContext)
        .environmentObject(DataController(inMemory: true))
        .environmentObject(LocationProvider.shared)
}
