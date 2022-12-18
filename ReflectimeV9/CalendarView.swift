//
//  CalendarView.swift
//  ReflectimeV9
//
//  Created by Ian Relecker on 12/8/22.


import SwiftUI
import RevenueCat

struct CalendarView: View {
    @FetchRequest(sortDescriptors: []) var reflection: FetchedResults<Reflection>
    
    @State private var dates = Date()
    @State private var something = 0
    
    @State private var dateSort  = false
    
    @State private var catasort = false
    @State private var cat = "General"
    var cats = ["General", "Personal", "Work", "Feelings", "Wishes", "Intrests"]
    
    @State private var reviewMonth = false
    @State private var setsubC = false
    
    let defaults = UserDefaults.standard
    
    
    var body: some View {
        NavigationView{
            if(defaults.bool(forKey: "pro") == true || defaults.integer(forKey: "views") < 500){
                //put in map view here
                Form{
                    Section{
                        if(defaults.bool(forKey: "pro") == false){
                            
                            HStack{
                                Spacer()
                                ZStack{
                                    Rectangle()
                                        .frame(width: 340, height: 30, alignment: .center)
                                        .foregroundColor(Color("BackColor"))
                                        .cornerRadius(10)
                                        .shadow(radius: 3)
                                        .onTapGesture{
                                            setsubC = true
                                            defaults.set(false, forKey: "warn")
                                        }
                                    Text("You have \(500 - defaults.integer(forKey: "views")) free results of sort remaining.")
                                        .fixedSize()
                                        .fontWeight(.light)
                                        .multilineTextAlignment(.center)
                                        .dynamicTypeSize(.medium)
                                        .allowsHitTesting(false)
                                }
                                Spacer()
                            }
                        }
                    }
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
                                        .fixedSize()
                                        .fontWeight(.light)
                                        .multilineTextAlignment(.center)
                                        .dynamicTypeSize(.medium)
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
                                            Text("\(reflect.name ?? "fail n")")
                                                .fontWeight(.light)
                                                .font(.title2)
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
                                        Rectangle()
                                            .frame(height: 1)
                                            .foregroundColor(Color("Background"))
                                        HStack{
                                            Text(reflect.date?.formatted(date: .long, time: .omitted) ?? "fail cata").fontWeight(.ultraLight)
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
                                        VStack{
                                            Rectangle()
                                                .frame(height: 1)
                                                .foregroundColor(Color("Background"))
                                            HStack{
                                                Spacer()
                                                Text(reflect.note ?? "fail note")
                                                    .multilineTextAlignment(.leading)
                                                    .fontWeight(.light)
                                                    .font(.title3)
                                                    .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
                                                
                                                
                                                Spacer()
                                            }
                                            
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
                                            Text("\(reflect.name ?? "fail n")")
                                                .fontWeight(.light)
                                                .font(.title2)
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
                                        Rectangle()
                                            .frame(height: 1)
                                            .foregroundColor(Color("Background"))
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
                                        VStack{
                                            Rectangle()
                                                .frame(height: 1)
                                                .foregroundColor(Color("Background"))
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
                                            Text("\(reflect.name ?? "fail n")")
                                                .fontWeight(.light)
                                                .font(.title2)
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
                                        Rectangle()
                                            .frame(height: 1)
                                            .foregroundColor(Color("Background"))
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
                                        VStack{
                                            Rectangle()
                                                .frame(height: 1)
                                                .foregroundColor(Color("Background"))
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
                                            Text("\(reflect.name ?? "fail n")")
                                                .fontWeight(.light)
                                                .font(.title2)
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
                                        Rectangle()
                                            .frame(height: 1)
                                            .foregroundColor(Color("Background"))
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
                                        VStack{
                                            Rectangle()
                                                .frame(height: 1)
                                                .foregroundColor(Color("Background"))
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
                
                //.navigationBarTitle("Reflect")
                
                .sheet(isPresented: $setsubC){
                    subscribeView().presentationDetents([PresentationDetent .large]).interactiveDismissDisabled(true)
                }
                
                .onAppear{
                    
                    print(defaults.bool(forKey: "pro"))
                }
                
            }
            
            else{
                subscribeView()
            }
            
        }
        
    }
    //func sortView() -> some View{}
}


struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
        
    }
}

