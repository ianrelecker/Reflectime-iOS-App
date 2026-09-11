import CoreData
import SwiftUI

struct opaquesortview: View {
    var onCompose: () -> Void = {}

    @FetchRequest(sortDescriptors: []) private var reflections: FetchedResults<Reflection>

    private var remaining: Int {
        max(0, 3 - reflections.count)
    }

    var body: some View {
        ContentUnavailableView {
            Label("Not enough to reflect on yet", systemImage: "sparkles")
        } description: {
            Text(remaining == 1
                 ? "Write 1 more reflection to unlock insights, streaks, and look-back."
                 : "Write \(remaining) more reflections to unlock insights, streaks, and look-back.")
        } actions: {
            Button("New Reflection", systemImage: "plus", action: onCompose)
                .buttonStyle(.glassProminent)
        }
    }
}

#Preview {
    opaquesortview()
        .environment(\.managedObjectContext, DataController(inMemory: true).container.viewContext)
}
