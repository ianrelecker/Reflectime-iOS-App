import CoreData
import SwiftUI

struct NotEnoughMapView: View {
    var onCompose: () -> Void = {}

    @FetchRequest(sortDescriptors: []) private var reflections: FetchedResults<Reflection>

    private var remaining: Int {
        max(0, 3 - reflections.filter(\.hasLocation).count)
    }

    var body: some View {
        ContentUnavailableView {
            Label("Not enough places yet", systemImage: "map")
        } description: {
            Text(remaining == 1
                 ? "Add location to 1 more reflection to see them on a map."
                 : "Add location to \(remaining) more reflections to see them on a map.")
        } actions: {
            Button("New Reflection", systemImage: "plus", action: onCompose)
                .buttonStyle(.glassProminent)
        }
    }
}

#Preview {
    NotEnoughMapView()
        .environment(\.managedObjectContext, DataController(inMemory: true).container.viewContext)
}
