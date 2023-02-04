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
    var cats = ["General", "Personal", "Work", "Feelings", "Wishes", "Intrests", "Love", "Activity"]
    
    @State private var reviewMonth = true
    
    let defaults = UserDefaults.standard
    
    
    var body: some View {
        NavigationView{
            if(reflection.count >= 3){
                    
                    Form{
                        /*
                        Section("Reflect"){
                            
                            Toggle(isOn: $reviewMonth){
                                Text("Show All Reflections")
                            }
                        }
                         */
                        Section("Sort"){/*
                            Toggle(isOn: $dateSort){
                                Text("Sort By Day")
                            }
                            if(dateSort){
                                ResetView()
                                DatePicker("Pick A Date To Reflect On:",selection: $dates, displayedComponents: .date)
                                
                                    .datePickerStyle(.compact)
                                    .fontWeight(.light)
                            }
                                         */
                            Toggle(isOn: $catasort){
                                Text("Sort By Catagory")
                            }
                                         
                            if(catasort){
                                Picker(selection: $cat, label: Text("Choose a Catagory").fontWeight(.light)) {
                                    ForEach(cats, id: \.self){
                                        Text($0)
                                    }
                                }.onAppear{
                                    reviewMonth.toggle()
                                }
                                .onDisappear{
                                    reviewMonth.toggle()
                                }
                            }
                            /*
                            if(catasort == true){
                                Button("Reset Sort"){
                                    reviewMonth = true
                                    catasort = false
                                    dates = Date()
                                    cat = "General"
                                }.foregroundColor(Color(UIColor.systemBlue))
                            }
                            */
                        }
                        
                        
                        Section("Results:"){
                            
                            if(something == 0){
                                HStack{
                                    Spacer()
                                    ZStack{
                                        Rectangle()
                                            .frame(width: 250, height: 60, alignment: .center)
                                            .foregroundColor(Color("BackColor"))
                                            .cornerRadius(15)
                                            .shadow(radius: 3)
                                        Text("No Results. Try another option.")
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
                                                    /*
                                                    Image(systemName: "location.circle.fill")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .foregroundColor(.blue)
                                                        .frame(width: 40, height: 40)
                                                        .disabled(true)
                                                     */
                                                }
                                            }
                                        }.onAppear{
                                            let value = defaults.integer(forKey: "views")
                                            defaults.set(value + 1, forKey: "views")
                                        }
                                    
                                    
                                }
                            }
                            /*
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
                            */
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
                            /*
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
                            */
                        }//form
                        
                    }
            }
            else{
                opaquesortview()
            }
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}


struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
        
    }
}

