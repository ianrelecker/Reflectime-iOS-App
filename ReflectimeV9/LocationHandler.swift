//
//  LocationHandler.swift
//  ReflectimeV9
//
//  Adapted by Ian Relecker on 11/26/22 from https://youtu.be/poSmKJ_spts.
//

import CoreLocation

class locationHandler: NSObject, ObservableObject {
    private let handler = CLLocationManager()
    @Published var user: CLLocation?
    static let share = locationHandler()
    
    override init(){
        super.init()
        handler.delegate = self
        handler.desiredAccuracy = kCLLocationAccuracyBest
        handler.startUpdatingLocation()
    }
    
    func request() {
        handler.requestWhenInUseAuthorization()
    }
    
    func getuser() -> (Double, Double){
        
        let latL = Double((user?.coordinate.latitude)!)
        let lonL = Double((user?.coordinate.longitude)!)
       
        return (latL, lonL)
    }
}
extension locationHandler: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locationM = locations.last else { return }
        self.user = locationM
    }
}
