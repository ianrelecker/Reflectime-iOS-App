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
    var body: some View {
        
        VStack{
            DatePicker("test", selection: $dates, displayedComponents: .date)
                .frame(width: 350, height: 300, alignment: .center)
                .padding(EdgeInsets(top: 15, leading: 10, bottom: 0, trailing: 10))
                .border(Color("Background"), width: 5)
                .cornerRadius(5)
                .datePickerStyle(.graphical)
            Form{
                ForEach(reflection){ reflect in
                    if(Calendar.current.dateComponents([.year, .month, .day], from: reflect.date ?? Date()) == Calendar.current.dateComponents([.year, .month, .day], from: dates)){
                        VStack{
                            //new layout for cal view
                            
                        }//v
                        
                            
                        }//if
                    }//for
                }//form
            }//V
            
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

