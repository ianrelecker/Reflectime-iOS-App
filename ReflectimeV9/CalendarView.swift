//
//  CalendarView.swift
//  ReflectimeV9
//
//  Created by Ian Relecker on 12/8/22.


import SwiftUI


struct NoteDetailC: View {
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


struct CalendarView: View {
    @FetchRequest(sortDescriptors: []) var reflection: FetchedResults<Reflection>
    
    @State private var dates = Date()
    @State private var something = 0
    var body: some View {
        
        VStack{
            
            Form{
                    HStack{
                        Spacer()
                        DatePicker("Pick A Date To Reflect On:",selection: $dates, displayedComponents: .date)
                        
                            .datePickerStyle(.compact)
                            .fontWeight(.light)
                            
                        Spacer()
                    }
                if(something == 0){
                    Text("no")
                }
                
                Section("Reflections"){
                    
                    ForEach(reflection){ reflect in
                        if(Calendar.current.dateComponents([.year, .month, .day], from: reflect.date ?? Date()) == Calendar.current.dateComponents([.year, .month, .day], from: dates)){
                            
                                
                                VStack{
                                    
                                    HStack{
                                        Text("Title: \(reflect.name ?? "fail n")")
                                            .fontWeight(.light)
                                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0))
                                        //.border(Color("Background"), width: 1)
                                        
                                        Spacer()
                                    }
                                    .onAppear{
                                        something+=1
                                    }
                                    .onDisappear{
                                        something-=1
                                    }
                                    HStack{
                                        Text(reflect.date?.formatted(date: .omitted, time: .shortened) ?? "fail cata").fontWeight(.ultraLight)
                                        Spacer()
                                    }
                                    HStack{
                                        Text("Catagory: \(reflect.cata ?? "fail n")")
                                            .font(.subheadline)
                                            .fontWeight(.ultraLight)
                                        //.padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
                                        //.border(Color("Background"), width: 1)
                                        
                                        Spacer()
                                    }
                                    HStack{
                                        Spacer()
                                        Text(reflect.note ?? "fail note")
                                            .multilineTextAlignment(.leading)
                                            .fontWeight(.light)
                                            .font(.title3)
                                            .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
                                        //.border(Color("Background"), width: 1)
                                        Spacer()
                                    }
                                    if(reflect.lon != 0){
                                        ZStack{
                                            MapView(place: IdentifiablePlace(id: UUID(), lat: reflect.lat, lon: reflect.lon))
                                                .disabled(true)
                                            Image(systemName: "location.circle.fill")
                                                .resizable()
                                                .scaledToFit()
                                                .foregroundColor(.blue)
                                                .frame(width: 40, height: 40)
                                                .disabled(true)
                                        }
                                    }
                                }
                            
                            //v
                            
                            
                            
                        }//if
                    }//for
                }//form
            }//V
        }
        }
    }
    /*
    func findreflection() -> Array<Reflection> {
        var arr = [Reflection()]
        for reflect in reflection {
            if (reflect.date == dates){
                arr.append(reflect)
            }
        }
        return arr
    }
     */

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
        
    }
}

