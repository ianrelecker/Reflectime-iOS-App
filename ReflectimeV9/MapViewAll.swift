//
//  MapViewAll.swift
//  ReflectimeV9
//
//  Created by Ian Relecker on 12/19/22.
//

import SwiftUI
import MapKit

struct Location: Identifiable, Codable, Equatable{
    let id: UUID
    let title: String
    let data: String
    let lat: Double
    let lon: Double
}

struct MapViewAll: View {
    @FetchRequest(sortDescriptors: []) var reflection: FetchedResults<Reflection>
    @State private var arr = [Location]()
    
    private let locationAdd = locationHandler()
    
    @State private var showname = 0.0
    
    @State var userloc = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 50, longitude: 50), span: MKCoordinateSpan(latitudeDelta: 2.5, longitudeDelta: 2.5))
    
    var body: some View {
        Map(coordinateRegion: $userloc, annotationItems: arr){ anno in
            MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: anno.lat, longitude: anno.lon)){
                VStack{
                    Image(systemName: "mappin")
                        .renderingMode(.original)
                        .imageScale(.large)
                        .onTapGesture {
                            if(showname == 0.0){
                                showname = 100.0
                            }else if(showname == 100.0){
                                showname = 0.0
                            }
                            print("yeah")
                        }
                    Text(anno.title).opacity(showname)
                    
                }
            }
        }
            .onAppear{
                getuserloc()
                getallLoc()
            }
            
    }
    
    func getallLoc(){
        for ref in reflection{
            let hold = Location(id: UUID(), title: ref.name ?? "Fail name", data: ref.note ?? "Fail note", lat: ref.lat, lon: ref.lon)
            arr.append(hold)
            
        }
    }
    
    func getuserloc(){
        let hold = locationAdd.user?.coordinate
        userloc = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: hold?.latitude ?? 50, longitude: hold?.longitude ?? 50), span: MKCoordinateSpan(latitudeDelta: 2.5, longitudeDelta: 2.5))
    }
}

struct MapViewAll_Previews: PreviewProvider {
    static var previews: some View {
        MapViewAll()
    }
}
