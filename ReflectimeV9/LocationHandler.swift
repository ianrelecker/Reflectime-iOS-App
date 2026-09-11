import CoreLocation
import Foundation

@MainActor
final class LocationProvider: NSObject, ObservableObject {
    static let shared = LocationProvider()

    @Published private(set) var user: CLLocation?
    @Published private(set) var authorization: CLAuthorizationStatus

    private let manager = CLLocationManager()

    var isAuthorized: Bool {
        authorization == .authorizedWhenInUse || authorization == .authorizedAlways
    }

    override init() {
        authorization = manager.authorizationStatus
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        if isAuthorized {
            manager.requestLocation()
        }
    }

    func requestAccess() {
        manager.requestWhenInUseAuthorization()
    }

    func refresh() {
        guard isAuthorized else { return }
        manager.requestLocation()
    }

    func coordinate() -> (Double, Double) {
        let latitude = user?.coordinate.latitude ?? 0
        let longitude = user?.coordinate.longitude ?? 0
        return (latitude, longitude)
    }
}

extension LocationProvider: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            authorization = manager.authorizationStatus
            if isAuthorized {
                manager.requestLocation()
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor in
            user = locations.last
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            if user == nil {
                user = manager.location
            }
        }
    }
}
