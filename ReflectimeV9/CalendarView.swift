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
    
    @State private var dateSort  = false
    
    @State private var catasort = false
    @State private var cat = "General"
    var cats = ["General", "Personal", "Work", "Feelings", "Wishes", "Intrests"]
    
    @State private var reviewMonth = false
    
    let defaults = UserDefaults.standard
    
    var body: some View {
        
        if(defaults.bool(forKey: "pro") || defaults.integer(forKey: "views") < 300){
            ZStack{
                VStack{
                    if(defaults.bool(forKey: "pro") == false){
                        Text("You have \(300 - defaults.integer(forKey: "views")) free results of sort remaining.")
                    }
                    Form{
                        Section("Reflect"){
                            Toggle(isOn: $reviewMonth){
                                Text("Reflect On Your Past Month")
                            }
                        }
                        Section("Sort"){
                            Toggle(isOn: $dateSort){
                                Text("Sort By Day")
                            }
                            if(dateSort){
                                DatePicker("Pick A Date To Reflect On:",selection: $dates, displayedComponents: .date)
                                
                                    .datePickerStyle(.compact)
                                    .fontWeight(.light)
                            }
                            Toggle(isOn: $catasort){
                                Text("Sort By Catagory")
                            }
                            if(catasort){
                                Picker(selection: $cat, label: Text("Choose a Catagory").fontWeight(.light)) {
                                    ForEach(cats, id: \.self){
                                        Text($0)
                                    }
                                }
                            }
                            if(catasort == true || dateSort == true || reviewMonth == true){
                                Button("Reset Sort"){
                                    reviewMonth = false
                                    catasort = false
                                    dateSort = false
                                    dates = Date()
                                    cat = "General"
                                }.foregroundColor(Color(UIColor.systemBlue))
                            }
                            
                        }
                        
                        
                        Section("Results:"){
                            if(something == 0 && !dateSort && !catasort && !reviewMonth){
                                HStack{
                                    Spacer()
                                    ZStack{
                                        Rectangle()
                                            .frame(width: 250, height: 60, alignment: .center)
                                            .foregroundColor(Color("BackColor"))
                                            .cornerRadius(15)
                                            .shadow(radius: 3)
                                        Text("Sort Through Your Reflections!\nTry Using An Option Above.")
                                            .fontWeight(.light)
                                            .multilineTextAlignment(.center)
                                    }
                                    Spacer()
                                }
                            }
                            //reflect month
                            if(reviewMonth){
                                ForEach(reflection){reflect in
                                    if(Calendar.current.dateComponents([.year, .month], from: Date()) == Calendar.current.dateComponents([.year, .month], from: reflect.date ?? Date())){
                                        
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
                                        }.onAppear{
                                            let value = defaults.integer(forKey: "views")
                                            defaults.set(value + 1, forKey: "views")
                                        }
                                    }
                                    
                                }
                            }
                            
                            //date
                            if(dateSort && !catasort){
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
                                        }.onAppear{
                                            let value = defaults.integer(forKey: "views")
                                            defaults.set(value + 1, forKey: "views")
                                        }
                                        
                                        //v
                                        
                                        
                                        
                                    }//if
                                }//for
                            }
                            //cata
                            if(catasort && !dateSort){
                                ForEach(reflection){ reflect in
                                    if(cat == reflect.cata ?? "General" ){
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
                                        }.onAppear{
                                            let value = defaults.integer(forKey: "views")
                                            defaults.set(value + 1, forKey: "views")
                                        }
                                        
                                        //v
                                        
                                        
                                        
                                    }
                                }
                            }
                            if(catasort && dateSort){
                                ForEach(reflection) { reflect in
                                    if(Calendar.current.dateComponents([.year, .month, .day], from: reflect.date ?? Date()) == Calendar.current.dateComponents([.year, .month, .day], from: dates) && cat == reflect.cata ?? "General"){
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
                                        }.onAppear{
                                            let value = defaults.integer(forKey: "views")
                                            defaults.set(value + 1, forKey: "views")
                                        }
                                    }
                                }
                            }
                            
                        }//form
                        
                    }
                    
                    //V
                    Rectangle()
                        .frame(width: 1, height: 0)
                        .foregroundColor(Color("BackColor"))
                        .ignoresSafeArea()
                }
                
            }
        }
        else{
            subscribeView()
        }
    }
    //func sortView() -> some View{}
}


struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
        
    }
}

