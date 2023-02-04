//
//  SettingsView.swift
//  ReflectimeV9
//
//  Created by Ian Relecker on 11/26/22.
//

import SwiftUI
import UserNotifications
import RevenueCat


struct SettingsView: View {
    private let locationAddH = locationHandler()
    @State var locationOn = locationOnF()
    @Environment(\.dismiss) var dismiss
    @State var notificationH = notificationTime()
    @State var notificationToggle = notificationStatus()
    @AppStorage("sendNot") var sendNot = true
    @AppStorage("showP") var showP = true
    @State var alertV = false
    @State var tex = ""
    
    
    
    let defaults = UserDefaults.standard
    
    
    var body: some View {
        NavigationView{
            Form{
                Section("Daily Notifications"){
                    DatePicker("Select A Time To Be Reminded To Reflect",selection: $notificationH, displayedComponents: .hourAndMinute)
                        .onChange(of: notificationH){ state in
                            NotificationClass().schedule(dateInput: notificationH)
                            let defaults = UserDefaults.standard
                            notificationH = defaults.object(forKey: "Date") as! Date
                            defaults.set(notificationToggle, forKey: "toggleNotify")
                            //defaults.set(showdate, forKey: "showdate")
                            print(Calendar.current.dateComponents([.minute], from: notificationH))
                            print(Calendar.current.dateComponents([.hour], from: notificationH))
                            defaults.set(sendNot, forKey: "sendNot")
                            defaults.set(showP, forKey: "showP")
                            print(state)
                        }
                        
                    
                    Toggle(isOn: $sendNot){
                        Text("Send Daily Notifications")
                    }
                    .onSubmit {
                        NotificationClass().schedule(dateInput: notificationH)
                        let defaults = UserDefaults.standard
                        notificationH = defaults.object(forKey: "Date") as! Date
                        defaults.set(notificationToggle, forKey: "toggleNotify")
                        //defaults.set(showdate, forKey: "showdate")
                        print(Calendar.current.dateComponents([.minute], from: notificationH))
                        print(Calendar.current.dateComponents([.hour], from: notificationH))
                        defaults.set(sendNot, forKey: "sendNot")
                        defaults.set(showP, forKey: "showP")
                    }
                }
                Section("Prompts"){
                    NavigationLink("Edit Your Prompts"){
                        PromptView()
                    }
                
                    Toggle(isOn: $showP){
                        Text("Show Prompts When Creating A New Reflection")
                    }.onSubmit {
                        NotificationClass().schedule(dateInput: notificationH)
                        let defaults = UserDefaults.standard
                        notificationH = defaults.object(forKey: "Date") as! Date
                        defaults.set(notificationToggle, forKey: "toggleNotify")
                        //defaults.set(showdate, forKey: "showdate")
                        print(Calendar.current.dateComponents([.minute], from: notificationH))
                        print(Calendar.current.dateComponents([.hour], from: notificationH))
                        defaults.set(sendNot, forKey: "sendNot")
                        defaults.set(showP, forKey: "showP")
                    }
                }
                
                Section("Support"){
                    Button("Privacy Policy"){
                        let urlP = URL(string: "https://www.ianrelecker.com/reflectime-app/privacy-policy")
                        UIApplication.shared.open(urlP!)
                    }.foregroundColor(Color.blue)
                    Button("EULA"){
                        let urlE = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")
                        UIApplication.shared.open(urlE!)
                    }.foregroundColor(Color.blue)
                    Button("Contact Us"){
                        let urlC = URL(string: "https://www.ianrelecker.com/contact")
                        UIApplication.shared.open(urlC!)
                    }.foregroundColor(Color.blue)
                }
                
                Section{
                    Button("Location Access"){
                        //
                    }
                    .foregroundColor(Color.blue)
                    .onTapGesture {
                        if !locationOn {
                            locationAddH.request()
                        }
                        if locationOn {
                            locationAddH.user = nil
                        }
                        locationOn.toggle()
                    }
                    
                    
                    Button("Notifcation Access"){
                        //
                    }
                    .foregroundColor(Color.blue)
                    .onTapGesture {
                        if(!notificationToggle){
                            NotificationClass().requestPermission()
                        }
                        notificationToggle.toggle()
                    }
                } header: {
                    Text("Prompt for Access")
                } footer: {
                    Text("These buttons will prompt the system for access for your location or notifications.\nIf nothing appears after you click these buttons,  enable this functionality in Settings.\nScroll down on the main page to \"Reflectime\" and provide access.")
                }
                
            }
            .navigationTitle("Settings")
            .onDisappear{
                NotificationClass().schedule(dateInput: notificationH)
                let defaults = UserDefaults.standard
                notificationH = defaults.object(forKey: "Date") as! Date
                defaults.set(notificationToggle, forKey: "toggleNotify")
                //defaults.set(showdate, forKey: "showdate")
                print(Calendar.current.dateComponents([.minute], from: notificationH))
                print(Calendar.current.dateComponents([.hour], from: notificationH))
                defaults.set(sendNot, forKey: "sendNot")
                defaults.set(showP, forKey: "showP")
                print("HERE" + "\(sendNot)")
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        
        
    }
    
}

func notificationStatus() -> Bool{
    let defaults = UserDefaults.standard
    return defaults.bool(forKey: "authorized")
}

func notificationTime() -> Date{
    let defaults = UserDefaults.standard
    var date = defaults.object(forKey: "Date")
    if (date == nil){
        print("nil date")
        date = Date()
    }
    return date as! Date
}


func locationOnF() -> Bool {
    if(locationHandler.share.user != nil){
        return true
    }else{
        return false
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
