import CoreData
import MapKit
import SwiftUI

struct ReflectionPin: Identifiable, Hashable {
    let id: UUID
    let title: String
    let coordinate: CLLocationCoordinate2D
    let objectID: NSManagedObjectID

    static func == (lhs: ReflectionPin, rhs: ReflectionPin) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct MapViewAll: View {
    var onCompose: () -> Void = {}

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Reflection.date, ascending: false)]
    ) private var reflections: FetchedResults<Reflection>
    @EnvironmentObject private var location: LocationProvider

    @State private var pins: [ReflectionPin] = []
    @State private var focusIndex = 0
    @State private var position: MapCameraPosition = .automatic
    @State private var opened: Reflection?
    @State private var showDetail = false

    private var locatedCount: Int {
        reflections.filter(\.hasLocation).count
    }

    private var pinSignature: Int {
        var hasher = Hasher()
        for reflection in reflections where reflection.hasLocation {
            hasher.combine(reflection.id)
            hasher.combine(reflection.lat)
            hasher.combine(reflection.lon)
            hasher.combine(reflection.name)
        }
        return hasher.finalize()
    }

    var body: some View {
        Group {
            if locatedCount < 3 {
                NotEnoughMapView(onCompose: onCompose)
            } else {
                Map(position: $position) {
                    ForEach(pins) { pin in
                        Annotation(pin.title, coordinate: pin.coordinate, anchor: .bottom) {
                            Button {
                                handlePinTap(pin)
                            } label: {
                                Image(systemName: isFocused(pin) ? "mappin.circle.fill" : "mappin.circle")
                                    .font(.title)
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(.white, isFocused(pin) ? Color.accentColor : Color.secondary)
                                    .shadow(radius: 2)
                            }
                            .accessibilityLabel(pin.title)
                            .accessibilityHint(isFocused(pin) ? "Opens this reflection" : "Zooms to this reflection")
                        }
                    }
                    if let user = location.user {
                        Annotation("You", coordinate: user.coordinate) {
                            Image(systemName: "location.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.white, Color.blue)
                        }
                    }
                }
                .mapStyle(.standard)
                .safeAreaInset(edge: .top) {
                    if let focused {
                        HStack {
                            Button {
                                open(focused)
                            } label: {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Places you’ve reflected")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text(focused.title)
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                        .lineLimit(1)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .buttonStyle(.plain)
                            .accessibilityHint("Opens this reflection")
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
        .navigationDestination(isPresented: $showDetail) {
            if let opened {
                NoteDetail(reflection: opened)
            }
        }
        .onAppear {
            rebuildPins()
            location.refresh()
        }
        .onChange(of: pinSignature) { _, _ in
            rebuildPins()
        }
    }

    private var focused: ReflectionPin? {
        guard pins.indices.contains(focusIndex) else { return pins.first }
        return pins[focusIndex]
    }

    private func isFocused(_ pin: ReflectionPin) -> Bool {
        focused?.id == pin.id
    }

    private func handlePinTap(_ pin: ReflectionPin) {
        if isFocused(pin) {
            open(pin)
            return
        }
        if let index = pins.firstIndex(where: { $0.id == pin.id }) {
            focusIndex = index
        }
        withAnimation {
            position = .region(
                MKCoordinateRegion(
                    center: pin.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
                )
            )
        }
    }

    private func open(_ pin: ReflectionPin) {
        if let match = reflections.first(where: { $0.objectID == pin.objectID }) {
            opened = match
            showDetail = true
            return
        }
        if let match = reflections.first(where: { $0.id == pin.id }) {
            opened = match
            showDetail = true
        }
    }

    private func rebuildPins() {
        pins = reflections.compactMap { reflection in
            guard reflection.hasLocation else { return nil }
            return ReflectionPin(
                id: reflection.id ?? UUID(),
                title: reflection.titleText,
                coordinate: reflection.coordinate,
                objectID: reflection.objectID
            )
        }
        if focusIndex >= pins.count {
            focusIndex = 0
        }
        if let focused {
            position = .region(
                MKCoordinateRegion(
                    center: focused.coordinate,
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
                        span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
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
