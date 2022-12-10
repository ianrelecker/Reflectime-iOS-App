//
//  IntroView.swift
//  ReflectimeV9
//
//  Created by Ian Relecker on 11/27/22.
//

import SwiftUI

struct IntroView: View {
    private let locationAddHI = locationHandler()
    @State var locationOnI = false
    
    @Environment(\.dismiss) var dismiss
    @State var notificationHI = notificationTimeI()
    @State var notificationToggleI = false
    
    let defaults = UserDefaults.standard
    
    var body: some View {
        NavigationView{
            VStack{
                
                Form{
                    Section{
                        HStack{
                            Text("Hi, My name is Ian! 🤗\n\n\tI created Reflectime to create a better outlet to help reflect on your day. What is going well, what is going not so well.\n\n\tThe most important thing that we can do is to increase communication with ourselfs overtime, and I hope that Reflectime does that for you.")
                                .fontWeight(.medium)
                                .onAppear{
                                    defaults.set(0, forKey: "views")
                                    defaults.set(true, forKey: "showP")
                                    defaults.set(true, forKey: "warn")
                                }
                        }
                    }
                    Toggle(isOn: $locationOnI){
                        Text("Reflectime only uses location permissions to add a location to your reflections. \nFor your privacy, this is only stored on your device. Please allow access while using the app.")
                            .fontWeight(.light)
                    }
                    .onTapGesture {
                        
                        if !locationOnI {
                            locationAddHI.request()
                        }
                        if locationOnI {
                            locationAddHI.user = nil
                        }
                        locationOnI.toggle()
                    }
                    
                    Toggle(isOn: $notificationToggleI){
                        Text("Like your location permission, notifications are used to remind you to reflect at the time you specify daily. Please click the toggle to the right and grant access.")
                            .fontWeight(.light)
                    }
                    .onTapGesture {
                        if(!notificationToggleI){
                            NotificationClass().requestPermission()
                        }
                        notificationToggleI.toggle()
                    }
                    
                    DatePicker("Select a time that you would want to be reminded to reflect. \nThis could be at the end of your day, or at another point where you have a few minutes of time.\n(You can change this in settings later.)",selection: $notificationHI, displayedComponents: .hourAndMinute)
                        .fontWeight(.light)
                    Section{
                        HStack{
                            Spacer()
                            ZStack{
                                Rectangle()
                                    .frame(width: 120, height: 45)
                                    .foregroundColor(Color("BW"))
                                    .cornerRadius(15)
                                    .onTapGesture {
                                        defaults.set(false, forKey: "showIntro")
                                        NotificationClass().schedule(dateInput: notificationHI)
                                        let defaults = UserDefaults.standard
                                        notificationHI = defaults.object(forKey: "Date") as! Date
                                        defaults.set(notificationToggleI, forKey: "toggleNotify")
                                        //defaults.set(showdate, forKey: "showdate")
                                        print(Calendar.current.dateComponents([.minute], from: notificationHI))
                                        print(Calendar.current.dateComponents([.hour], from: notificationHI))
                                        dismiss()
                                    }
                                Text("Close")
                                    .foregroundColor(Color("WB"))
                                    .shadow(radius: 40)
                                    .onTapGesture {
                                        defaults.set(false, forKey: "showIntro")
                                        NotificationClass().schedule(dateInput: notificationHI)
                                        let defaults = UserDefaults.standard
                                        notificationHI = defaults.object(forKey: "Date") as! Date
                                        defaults.set(notificationToggleI, forKey: "toggleNotify")
                                        //defaults.set(showdate, forKey: "showdate")
                                        print(Calendar.current.dateComponents([.minute], from: notificationHI))
                                        print(Calendar.current.dateComponents([.hour], from: notificationHI))
                                        dismiss()
                                    }
                            }//z
                            Spacer()
                        }//h
                    }//section
                }//closing form
                
                
            }//closing v
        }//closing navview
        
    }//closing view
}//closing struct

func notificationStatusI() -> Bool{
    let defaults = UserDefaults.standard
    //print(defaults.bool(forKey: "authorized"))
    return defaults.bool(forKey: "authorized")
}

func notificationTimeI() -> Date{
    let defaults = UserDefaults.standard
    var date = defaults.object(forKey: "Date")
    if (date == nil){
        print("nil date")
        date = Date()
    }
    return date as! Date
}


func locationOnFI() -> Bool {
    if(locationHandler.share.user != nil){
        return true
    }else{
        return false
    }
}

struct IntroView_Previews: PreviewProvider {
    static var previews: some View {
        IntroView()
    }
}
