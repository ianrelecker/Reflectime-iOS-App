//
//  MapView.swift
//  ReflectimeV9
//
//  Adapted by Ian Relecker from https://developer.apple.com/documentation/mapkit/mapannotation
// and https://codewithchris.com/swiftui/swiftui-apple-maps/
//

import SwiftUI
import CoreLocation
import MapKit

struct IdentifiablePlace: Identifiable{
    let id: UUID
    let location: CLLocationCoordinate2D
    init(id: UUID, lat: Double, lon: Double) {
        self.id = id
        self.location = CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}

struct MapView: View {
    @ObservedObject var locationhandler = locationHandler.share
    let place: IdentifiablePlace

    let defaults = UserDefaults.standard
    var body: some View {
            Map(coordinateRegion: .constant(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: place.location.latitude, longitude: place.location.longitude), span: MKCoordinateSpan(latitudeDelta: 0.12, longitudeDelta: 0.12))), annotationItems: [place]) {place in
                MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: place.location.latitude, longitude: place.location.longitude)){
                    
                    Image(systemName: "location.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.blue)
                        .frame(width: 20, height: 20)
                     
                }
            }
            .onTapGesture {
                //causes purple error
                
                print("url")
                let url = URL(string: "maps://?saddr=&daddr=\(place.location.latitude),\(place.location.longitude)")
                if UIApplication.shared.canOpenURL(url!){
                    UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                }
                 
                
            }
            .disabled(false)
            .frame(height: 150)
            .cornerRadius(10)
            .onAppear{
                UIApplication.shared.applicationIconBadgeNumber = 0
            }
    }
}



struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(locationhandler: locationHandler.share, place: IdentifiablePlace(id: UUID(), lat: 37.0, lon: 120.0))
    }
}
