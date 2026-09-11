import CoreData
import SwiftUI

struct SearchView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Reflection.date, ascending: false)],
        animation: .default
    ) private var reflections: FetchedResults<Reflection>

    @State private var searchText = ""

    private var results: [Reflection] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let items = Array(reflections)
        guard !query.isEmpty else { return items }
        return items.filter { reflection in
            reflection.titleText.localizedCaseInsensitiveContains(query)
                || reflection.bodyText.localizedCaseInsensitiveContains(query)
                || reflection.categoryName.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        List {
            if results.isEmpty {
                ContentUnavailableView.search(text: searchText)
            } else {
                ForEach(results, id: \.objectID) { reflection in
                    NavigationLink {
                        NoteDetail(reflection: reflection)
                    } label: {
                        ReflectionRow(reflection: reflection)
                    }
                }
            }
        }
        .navigationTitle("Search")
        .searchable(text: $searchText, placement: .automatic, prompt: "Titles, thoughts, categories")
        .scrollEdgeEffectStyle(.soft, for: .top)
    }
}

#Preview {
    NavigationStack {
        SearchView()
    }
    .environment(\.managedObjectContext, DataController(inMemory: true).container.viewContext)
}
