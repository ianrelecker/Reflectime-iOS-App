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
                                Text("Title:")
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
                                    
                                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0))
                                    //.border(Color(UIColor.systemGray4), width: 4)
                                    .cornerRadius(5)
                                
                                Spacer()
                            }
                        }
                    }
                    Text("\(reflection.date?.formatted(date: .complete, time: .shortened) ?? Date().formatted())")
                                            .foregroundColor(Color("Background"))
                                            .font(.caption)
                    VStack{
                             if (reflection.lon != 0){
                                 /*
                             Text("You were here:").foregroundColor(Color("Background"))
                             .frame(maxWidth: .infinity, alignment: .leading)
                             .font(.caption)
                                 */
                                 ZStack{
                                     MapView(place: IdentifiablePlace(id: UUID(), lat: reflection.lat, lon: reflection.lon))
                                         
                                     /*
                                     Image(systemName: "location.circle.fill")
                                         .resizable()
                                         .scaledToFit()
                                         .foregroundColor(.blue)
                                         .frame(width: 40, height: 40)
                                         .disabled(true)
                                      */
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
    
    @State private var holdingdisText = ""
    
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
                                    VStack{
                                        HStack{
                                            ZStack{
                                                Rectangle()
                                                    .cornerRadius(15)
                                                    .foregroundColor(Color(UIColor.systemGray6))
                                                    .opacity(20)
                                                    .frame(width: 50, height: 50)
                                                VStack{
                                                    Text(reflect.date?.formatted(.dateTime.month(.abbreviated)) ?? "Fail c")
                                                        .foregroundColor(Color("First"))
                                                        .fontWeight(.light)
                                                    Text(reflect.date?.formatted(.dateTime.day()) ?? "Fail c")
                                                        .fontWeight(.light)
                                                        .foregroundColor(Color("First"))
                                                }
                                            }
                                            
                                            VStack{
                                                HStack{
                                                    Text(reflect.name ?? "Fail n")
                                                        .font(.body)
                                                        
                                                    Spacer()
                                                }
                                                Rectangle()
                                                    .frame(height: 1)
                                                    .foregroundColor(Color("Background"))
                                                    .ignoresSafeArea()
                                                    .padding(EdgeInsets(top: -5, leading: 0, bottom: 0, trailing: 0))
                                                HStack{
                                                    
                                                    let txt = (reflect.note ?? "Fail note")
                                                        
                                                    TextField(txt, text: $holdingdisText)
                                                        .fontWeight(.medium)
                                                        .disabled(true)
                                                        .allowsHitTesting(false)
                                                        .padding(EdgeInsets(top: -5, leading: 0, bottom: 0, trailing: 0))
                                                    /*
                                                    Text("\(String(txt))...")
                                                        .fontWeight(.ultraLight)
                                                        .dynamicTypeSize(.small)
                                                     */
                                                    Spacer()
                                                }
                                            }
                                        }
                                        
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
                    EditButton().disabled(editdis())
                    Button{
                        //this was the cause of the first issue
                        //print("\(getPro())" + "GetPro")
                        
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
                        .interactiveDismissDisabled(true)
                }
                .sheet(isPresented: $showSettings){
                    SettingsView().presentationDetents([PresentationDetent .large])
                }//end sett
                .sheet(isPresented: $showIntro){
                    IntroView().presentationDetents([PresentationDetent .fraction(0.9)]).interactiveDismissDisabled(true)
                }//end intro
                .sheet(isPresented: $showAdd){
                    NoteAdd().presentationDetents([PresentationDetent .large])
                }//end add
                .navigationTitle(Text("Reflectime"))
                .onAppear{
                    UIApplication.shared.applicationIconBadgeNumber = 0
                }
                
            }//end navview
            .navigationViewStyle(StackNavigationViewStyle())
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
                        .fixedSize()
                        .dynamicTypeSize(.medium)
                }
                
            }
            Spacer()
        }//end Z
        
        
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
           try?moc.save()
           
       }
       
   }
    
    
}// end contentview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
        
    }
}
