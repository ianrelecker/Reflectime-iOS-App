//
//  IntroView.swift
//  ReflectimeV9
//
//  Created by Ian Relecker on 11/27/22.
//

import SwiftUI

struct IntroView: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: []) var motivations: FetchedResults<Motivations>
    
    private let locationAddHI = locationHandler()
    @State var locationOnI = false
    
    @Environment(\.dismiss) var dismiss
    @State var notificationHI = notificationTimeI()
    @State var notificationToggleI = false
    @State private var introToggleDisable = false
    
    let defaults = UserDefaults.standard
    
    var body: some View {
        NavigationView{
            VStack{
                
                Form{
                    
                        HStack{
                            Text("Hi, My name is Ian! 🤗\n\tI created Reflectime to create a better outlet to help reflect on your day.")
                                .fontWeight(.medium)
                                .onAppear{
                                    defaults.set(0, forKey: "views")
                                    defaults.set(true, forKey: "showP")
                                    defaults.set(true, forKey: "warn")
                                    defaults.set(0, forKey: "prom")
                                    
                                    let motivation = ["Write down what you are thinking about now. Could be issues you are having, something you want, goals you are working to. \n \nWrite down what you are thinking, reflect on your thoughts.", "Try seperating your thoughts into different sections. If your main thought is a difficulty, what part of your life is this in?", "Be honest with yourself, if you think something isn't going right, reflect on that. What is the issue you are running into? How would someone else deal with this?", "What are you celebrating today? What was something you learned, got better at, or practiced?", "What is a long term project of yours?", "Who are you comparing yourself to? Is this healthy?", "Why are you amazing!", "What is the best thing that has happened today?", "What did you just complete?", "What are you looking forward to?", "How can you make this next week better than the last?", "What do you want more of?", "You are the best.", "How was your day?", "Reflect on the most impactful thing you did.", "Reflect on what made you upset.", "Reflect on what made you happy.", "Reflect on what you are proud of."]
                                    //needs fixing
                                    /*
                                    for mot in motivation{
                                        for mop in motivations{
                                            if(mot != mop.item ?? "`"){
                                                let con = Motivations(context: moc)
                                                con.date = Date()
                                                con.item = mot
                                                try?moc.save()
                                            }
                                        }
                                    }
                                    */
                                    //works but has edge case
                                    for mot in motivation{
                                        let con = Motivations(context: moc)
                                        con.item = mot
                                        con.date = Date()
                                        try?moc.save()
                                    }
                                    //
                                }
                        }
                    
                    
                    
                    HStack{
                        Text("Your location data is only stored on device and kept private to you. No one else but you can see it. Your location data is used to display on the Map on a reflection where it is enabled.").fontWeight(.light)
                        ZStack{
                            Rectangle()
                                .frame(width: 100, height: 40, alignment: .center)
                                .fixedSize()
                                .foregroundColor(Color("BW"))
                                .cornerRadius(15)
                                .onTapGesture {
                                    if !locationOnI {
                                        locationAddHI.request()
                                    }
                                    if locationOnI {
                                        locationAddHI.user = nil
                                    }
                                    locationOnI = true
                                }
                            Text("Activate")
                                .foregroundColor(Color("WB"))
                                .fontWeight(.light)
                                .allowsHitTesting(false)
                        }
                    }
                    
                    HStack{
                        Text("Like your location permission, notifications are used to remind you to reflect at the time you specify daily. Please click the toggle to the right and grant access.").fontWeight(.light)
                        ZStack{
                            Rectangle()
                                .frame(width: 100, height: 40, alignment: .center)
                                .fixedSize()
                                .foregroundColor(Color("BW"))
                                .cornerRadius(15)
                                .onTapGesture {
                                    if(!notificationToggleI){
                                        NotificationClass().requestPermission()
                                    }
                                    notificationToggleI = true
                                }
                            Text("Activate")
                                .foregroundColor(Color("WB"))
                                .fontWeight(.light)
                                .allowsHitTesting(false)
                        }
                    }
                    
                    
                    DatePicker("Select a time that you would want to be reminded to reflect. \nThis could be at the end of your day, or at another point where you have a few minutes of time.\n(You can change this in settings later.)",selection: $notificationHI, displayedComponents: .hourAndMinute)
                        .fontWeight(.light)
                    Section{
                        
                    }//section
                }//closing form
                
                
            }//closing v
            .toolbar{
                Text("Close")
                    .foregroundColor(Color.blue)
                    .onTapGesture {
                        defaults.set(false, forKey: "showIntro")
                        NotificationClass().schedule(dateInput: notificationHI)
                        let defaults = UserDefaults.standard
                        notificationHI = defaults.object(forKey: "Date") as! Date
                        defaults.set(notificationToggleI, forKey: "toggleNotify")
                        print(Calendar.current.dateComponents([.minute], from: notificationHI))
                        print(Calendar.current.dateComponents([.hour], from: notificationHI))
                        dismiss()
                    }
            }
        }//closing navview
        
    }//closing view
}//closing struct

/*
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
        
    }//z
    
}//h
 */


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
