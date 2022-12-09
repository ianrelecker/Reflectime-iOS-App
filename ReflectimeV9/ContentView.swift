//
//  ContentView.swift
//  ReflectimeV9
//
//  Created by Ian Relecker on 10/29/22.
//  Nav view section for each adapted from https://www.youtube.com/watch?v=nViffcoa-Ec
//  Map View adapted from https://developer.apple.com/documentation/mapkit/
//

import SwiftUI
import MapKit
import CoreLocation
import UserNotifications
import CoreData
import RevenueCat




struct NoteDetail: View {
    let reflection: Reflection

    @ObservedObject var locationhandler = locationHandler.share
    
    
    @State private var showedit = false
    @State private var showMap = locationHandler.share.user
    @AppStorage("showW") var showW = false
    
    @AppStorage("sub") var sub = false
    
    var body: some View{
        //NavigationView{
                Form{
                    Section{
                        VStack{
                            HStack{
                                Text("Title of your Reflection:")
                                    .foregroundColor(Color("Background"))
                                    .fontWeight(.light)
                                    .opacity(5)
                                Spacer()
                            }
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(Color("Background"))
                            HStack{
                                Text(reflection.name ?? "Fail")
                                    .foregroundColor(Color("Background"))
                                    .font(.title)
                                Spacer()
                            }
                        }
                    }
                    
                    Section{
                        VStack{
                            HStack{
                                Text("Your Thought:")
                                    .opacity(5)
                                    .foregroundColor(Color("Background"))
                                    .fontWeight(.light)
                                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                                Spacer()
                            }
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(Color("Background"))
                            HStack{
                                Text(reflection.note ?? "Fail")
                                    .foregroundColor(Color("Background"))
                                    .font(.title2)
                                    .fontWeight(.light)
                                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0))
                                    //.border(Color(UIColor.systemGray4), width: 4)
                                    .cornerRadius(5)
                                
                                Spacer()
                            }
                        }
                    }
                    Text("Created: " + "\(reflection.date?.formatted(date: .complete, time: .shortened) ?? Date().formatted())")
                                            .foregroundColor(Color("Background"))
                                            .font(.caption)
                    VStack{
                             if (reflection.lon != 0){
                             Text("You were here when this reflection was created:").foregroundColor(Color("Background"))
                             .frame(maxWidth: .infinity, alignment: .leading)
                             .font(.caption)
                                 ZStack{
                                     MapView(place: IdentifiablePlace(id: UUID(), lat: reflection.lat, lon: reflection.lon))
                                         .disabled(true)
                                     Image(systemName: "location.circle.fill")
                                         .resizable()
                                         .scaledToFit()
                                         .foregroundColor(.blue)
                                         .frame(width: 40, height: 40)
                                         .disabled(true)
                                 }
                             
                             }else{
                             Text("Location Not Included In This Reflection")
                             .foregroundColor(Color("Background"))
                             .font(.caption)
                             
                             }
                             
                    }//v
                    
                    
                }//f
                
                
        //}//nav
        .sheet(isPresented: $showedit){
            EditView(reflection: reflection).presentationDetents([PresentationDetent .fraction(0.7)])
        }
        .toolbar{
            
                ZStack{
                    
                    Rectangle()
                        .cornerRadius(10)
                        .foregroundColor(Color(UIColor.systemGray5))
                        .frame(width: 60, height: 30)
                        .ignoresSafeArea()
                    Button{
                        showedit = true
                    }label: {
                        Text("Edit")
                            .fontWeight(.light)
                            .foregroundColor(Color(UIColor.systemBlue))
                    }
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 8))
                }.padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 30))
                
            
        }
    }//body
}//view


struct ContentView: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: []) var reflections: FetchedResults<Reflection>
    
    
    
    @ObservedObject var locationhandler = locationHandler.share
    
    @State private var showAdd = false
    @State private var showSettings = false
    let defaults = UserDefaults.standard
    @AppStorage("showIntro") var showIntro = true
    
    @State private var showdia = false
    
    @State private var showcount = true
    
    
    var body: some View {
        ZStack{
            
            NavigationView{
                List(){
                    ForEach(reflections){ reflect in
                            //["General", "Personal", "Work", "Feelings", "Wishes", "Intrests"]
                            Section(reflect.cata ?? "Fail Sc"){
                                NavigationLink{
                                    NoteDetail(reflection: reflect.self)
                                        .onAppear{showcount = false}
                                }
                                
                                label: {
                                    HStack{
                                        ZStack{
                                            Rectangle()
                                                .cornerRadius(15)
                                                .foregroundColor(Color(UIColor.systemGray6))
                                                .opacity(20)
                                                .frame(width: 50)
                                            VStack{
                                                Text(reflect.date?.formatted(.dateTime.month(.abbreviated)) ?? "Fail c")
                                                    .foregroundColor(Color("First"))
                                                    .fontWeight(.light)
                                                Text(reflect.date?.formatted(.dateTime.day()) ?? "Fail c")
                                                    .fontWeight(.light)
                                                    .foregroundColor(Color("First"))
                                            }
                                        }
                                        
                                        Text(reflect.name ?? "Fail n")
                                            .fontWeight(.light)
                                    }
                                }
                                .allowsHitTesting(false)
                                
                            }
                        
                    }
                    .onDelete(perform: removeItems)
                }
                .onAppear{
                    showcount = true
                    //defaults.set(false, forKey: "dis")
                }
                //end list
                .toolbar{
                    if(reflections.count != 0){
                        ZStack{
                            Rectangle()
                                .frame(width: 80, height: 30)
                                .foregroundColor(Color(UIColor.systemGray5))
                                .cornerRadius(10)
                            Text("Count: \(reflections.count)")
                        }
                    }
                    /*
                    Button{
                        showSettings = true
                    }label: {
                        Image(systemName: "gear")
                    }//end button
                     */
                    EditButton().disabled(editdis())
                    Button{
                        print("\(getPro())" + "GetPro")
                        
                        showAdd = true
                        /*
                        if(getPro() == true){
                            
                            showAdd = true
                        }
                        else if(getPro() == false && reflections.count > 6){
                            showdia = true
                        }
                        else if(getPro() == false && reflections.count <= 6){
                            showAdd = true
                        }
                        */
                        
                    }label: {
                        Image(systemName: "plus")
                    }//end button
                }//end toolbar
                .sheet(isPresented: $showdia){
                    subscribeView().presentationDetents([PresentationDetent .large])
                }
                .sheet(isPresented: $showSettings){
                    SettingsView().presentationDetents([PresentationDetent .large])
                }//end sett
                .sheet(isPresented: $showIntro){
                    IntroView().presentationDetents([PresentationDetent .fraction(0.9)])
                }//end intro
                .sheet(isPresented: $showAdd){
                    NoteAdd().presentationDetents([PresentationDetent .large])
                }//end add
                .navigationTitle(Text("Reflectime"))
                .onAppear{
                    UIApplication.shared.applicationIconBadgeNumber = 0
                }
                
            }//end navview
            
            .onAppear{
                UIApplication.shared.applicationIconBadgeNumber = 0
            }
            
            if(reflections.count == 0){
                ZStack{
                    Rectangle()
                        .frame(width: 300, height: 60, alignment: .center)
                        .foregroundColor(Color("BackColor"))
                        .cornerRadius(15)
                        .shadow(radius: 3)
                    Text("Create a new Reflection by clicking\nthe \"\(Image(systemName: "plus"))\" icon in the top right.")
                        .fontWeight(.light)
                        .multilineTextAlignment(.center)
                }
                
            }
        }//end Z
        
        /*
        if(showcount){
            ZStack{
                if(reflections.count == 0){
                    Rectangle()
                        .cornerRadius(15)
                        .foregroundColor(Color(UIColor.systemGray6))
                        .opacity(20)
                        .frame(height: 50)
                    HStack{
                        Spacer()
                        Text("You don't have any reflections. Use the \"Plus\" icon at the top right to create one.")
                            .fontWeight(.light)
                            .multilineTextAlignment(.center)
                            .onAppear{
                                defaults.set(true, forKey: "showP")
                            }
                        Spacer()
                    }
                }else{
                    Rectangle()
                        .cornerRadius(15)
                        .foregroundColor(Color(UIColor.systemGray6))
                        .opacity(20)
                        .frame(width: 100, height: 50)
                    Text("Count: " + "\(reflections.count)")
                        .fontWeight(.light)
                }
            }
        }
        */
        
    }//end body

    func editdis() -> Bool{
        if(reflections.count == 0){
            return true
        }else{
            return false
        }
    }
    
    func getPro() -> Bool{
        if defaults.bool(forKey: "pro") == true {
            return true
        } else {
            return false
            
        }
    }
    
    func showIntroF() -> Bool {
        let defaults = UserDefaults.standard
        return defaults.bool(forKey: "showIntro")
    }
   func removeItems(offsets: IndexSet) {
       for offset in offsets{
           let reflection = reflections[offset]
           moc.delete(reflection)
       }
   }
    
    
}// end contentview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
        
    }
}
