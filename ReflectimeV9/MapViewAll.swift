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
    var foc: Bool
}

struct MapViewAll: View {
    @FetchRequest(sortDescriptors: []) var reflection: FetchedResults<Reflection>
    @State private var arr = [Location]()
    
    
    private let locationAdd = locationHandler()
    
    @State private var showname = 0.0
    
    @State private var textfoc = ""
    @State private var indfoc = 0
    
    @State private var fake = ""
    
    
    @State var userloc = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 50, longitude: 50), span: MKCoordinateSpan(latitudeDelta: 0.12, longitudeDelta: 0.12))
    
    var body: some View {
        
        
        VStack{
            if(arr.count >= 3){
            HStack{
                Spacer()
                Text("Click through your reflections!")
                    .fontWeight(.bold)
                    .foregroundColor(Color("BW"))
                    .dynamicTypeSize(.medium)
                Spacer()
                /*
                Image(systemName: "chevron.left")
                    .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
                    .frame(width: 25, height: 25)
                    .imageScale(.large)
                 
                Rectangle()
                    .frame(width: 0, height: 1)
                    .opacity(0)
                 */
                Image(systemName: "chevron.right")
                    .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
                    .frame(width: 25, height: 25)
                    .imageScale(.large)
                    .onTapGesture {
                        getnextloc()
                    }
                Rectangle()
                    .frame(width: 35, height: 1)
                    .opacity(0)
            }
                Map(coordinateRegion: $userloc, annotationItems: arr){ anno in
                    MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: anno.lat, longitude: anno.lon)){
                        VStack{
                            Image(systemName: "mappin")
                                .renderingMode(.original)
                                .imageScale(.large)
                            
                            ZStack{
                               
                                if(anno.foc == true){
                                    Text(anno.title)
                                        .fontWeight(.medium)
                                        .disabled(true)
                                        .allowsHitTesting(false)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color(.black))
                                        .padding(EdgeInsets(top: 3, leading: 3, bottom: 3, trailing: 3))
                                        .background(Color(UIColor.systemGray3))
                                        .cornerRadius(10)
                                }
                                
                                    
                               /*
                                    Text(textfoc)
                                        .foregroundColor(Color("WB"))
                                        .dynamicTypeSize(.medium)
                                        .disabled(true)
                                        .allowsHitTesting(false)
                                        .frame(height: 20, alignment: .center)
                                */
                            }//.background(Color("BW"))
                            
                            
                            
                        }
                    }
                }
            }else{
                NotEnoughMapView()
            }
            //.ignoresSafeArea(edges: .top)
        }
        .onAppear{
            getuserloc()
            getallLoc()
            getnextloc()
        }
        .onDisappear{
            arr = [Location]()
        }
        
    }
    
    func getnextloc(){
        
        if(indfoc == arr.count){
            indfoc = 0
        }
        
        /*
        if(indfoc == 0){
            arr[indfoc].foc = true
        }else{
            arr[indfoc-1].foc = false
            arr[indfoc].foc = true
        }
         */
        let hold = arr[indfoc]
        if(indfoc != 0){
            arr[indfoc-1].foc = false
        }else{
            arr[arr.count-1].foc = false
        }
        print(userloc)
        print("\(indfoc) indfoc")
        print("\(arr[indfoc].title) arr")
        userloc = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: hold.lat, longitude: hold.lon), span: MKCoordinateSpan(latitudeDelta: 0.12, longitudeDelta: 0.12))
        print("After \(userloc)")
        arr[indfoc].foc = true
        indfoc = indfoc + 1
        
        
        
    }
    
    
    func getallLoc(){
        for ref in reflection{
            let hold = Location(id: UUID(), title: ref.name ?? "Fail name", data: ref.note ?? "Fail note", lat: ref.lat, lon: ref.lon, foc: false)
            if(ref.lat != 0.0){
                arr.append(hold)
            }
        }
    }
    
    func getuserloc(){
        let hold = locationAdd.user?.coordinate
        userloc = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: hold?.latitude ?? 50, longitude: hold?.longitude ?? 50), span: MKCoordinateSpan(latitudeDelta: 0.12, longitudeDelta: 0.12))
    }
}

struct MapViewAll_Previews: PreviewProvider {
    static var previews: some View {
        MapViewAll()
    }
}
