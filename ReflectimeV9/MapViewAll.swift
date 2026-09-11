import CoreData
import MapKit
import SwiftUI

struct ReflectionPin: Identifiable, Hashable {
    let id: UUID
    let title: String
    let coordinate: CLLocationCoordinate2D

    static func == (lhs: ReflectionPin, rhs: ReflectionPin) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct MapViewAll: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Reflection.date, ascending: false)]
    ) private var reflections: FetchedResults<Reflection>
    @EnvironmentObject private var location: LocationProvider

    @State private var pins: [ReflectionPin] = []
    @State private var focusIndex = 0
    @State private var position: MapCameraPosition = .automatic

    private var locatedCount: Int {
        reflections.filter(\.hasLocation).count
    }

    var body: some View {
        Group {
            if locatedCount < 3 {
                NotEnoughMapView()
            } else {
                Map(position: $position) {
                    ForEach(pins) { pin in
                        Marker(pin.title, coordinate: pin.coordinate)
                            .tint(pins.indices.contains(focusIndex) && pins[focusIndex].id == pin.id ? .accentColor : .secondary)
                    }
                    if let user = location.user {
                        Marker("You", systemImage: "location.fill", coordinate: user.coordinate)
                            .tint(.blue)
                    }
                }
                .mapStyle(.standard)
                .safeAreaInset(edge: .top) {
                    if let focused {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Places you’ve reflected")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(focused.title)
                                    .font(.headline)
                                    .lineLimit(1)
                            }
                            Spacer()
                            Button("Next", systemImage: "chevron.right") {
                                showNext()
                            }
                            .labelStyle(.iconOnly)
                            .buttonStyle(.glass)
                            .accessibilityLabel("Next reflection")
                        }
                        .padding(16)
                        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                }
            }
        }
        .navigationTitle("Map")
        .onAppear {
            rebuildPins()
            location.refresh()
        }
        .onChange(of: reflections.count) { _, _ in
            rebuildPins()
        }
    }

    private var focused: ReflectionPin? {
        guard pins.indices.contains(focusIndex) else { return pins.first }
        return pins[focusIndex]
    }

    private func rebuildPins() {
        pins = reflections.compactMap { reflection in
            guard reflection.hasLocation else { return nil }
            return ReflectionPin(
                id: reflection.id ?? UUID(),
                title: reflection.titleText,
                coordinate: reflection.coordinate
            )
        }
        focusIndex = 0
        if let first = pins.first {
            position = .region(
                MKCoordinateRegion(
                    center: first.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.18, longitudeDelta: 0.18)
                )
            )
        }
    }

    private func showNext() {
        guard !pins.isEmpty else { return }
        focusIndex = (focusIndex + 1) % pins.count
        if let focused {
            withAnimation {
                position = .region(
                    MKCoordinateRegion(
                        center: focused.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.12, longitudeDelta: 0.12)
                    )
                )
            }
        }
    }
}

#Preview {
    NavigationStack {
        MapViewAll()
    }
    .environment(\.managedObjectContext, DataController(inMemory: true).container.viewContext)
    .environmentObject(LocationProvider.shared)
}
