import MapKit
import SwiftUI

struct IdentifiablePlace: Identifiable, Hashable {
    let id: UUID
    let location: CLLocationCoordinate2D

    init(id: UUID, lat: Double, lon: Double) {
        self.id = id
        self.location = CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    static func == (lhs: IdentifiablePlace, rhs: IdentifiablePlace) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct MapView: View {
    let place: IdentifiablePlace
    var interactive = true

    @State private var position: MapCameraPosition

    init(place: IdentifiablePlace, interactive: Bool = true) {
        self.place = place
        self.interactive = interactive
        _position = State(
            initialValue: .region(
                MKCoordinateRegion(
                    center: place.location,
                    span: MKCoordinateSpan(latitudeDelta: 0.12, longitudeDelta: 0.12)
                )
            )
        )
    }

    var body: some View {
        Map(position: $position) {
            Marker("Reflection", coordinate: place.location)
                .tint(Color.accentColor)
        }
        .mapStyle(.standard)
        .frame(height: 180)
        .clipShape(.rect(cornerRadius: 12))
        .onTapGesture {
            guard interactive else { return }
            zoomIn()
        }
        .accessibilityAddTraits(interactive ? .isButton : [])
        .accessibilityLabel("Map of this reflection")
        .accessibilityHint(interactive ? "Zooms in" : "")
    }

    private func zoomIn() {
        withAnimation {
            position = .region(
                MKCoordinateRegion(
                    center: place.location,
                    span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
                )
            )
        }
    }
}

#Preview {
    MapView(place: IdentifiablePlace(id: UUID(), lat: 34.0522, lon: -118.2437))
        .padding()
}
