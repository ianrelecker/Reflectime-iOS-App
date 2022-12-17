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
    //@State var notificationOn = false
    @Environment(\.dismiss) var dismiss
    @State var notificationH = notificationTime()
    @State var notificationToggle = notificationStatus()
    //@State var showdate = showdateF()
    //@State var showIntro = showIntroF()
    @AppStorage("sendNot") var sendNot = true
    @AppStorage("showP") var showP = true
    @State var setsub = setsubF()
    
    @State var alertV = false
    @State var alertProList = false
    @State var tex = ""
    
    
    
    let defaults = UserDefaults.standard
    
    
    var body: some View {
        //add about switching out prompts
        NavigationView{
            Form{
                /*
                //ADD THE NAME HERE AND THEN INTRODUCE IT ON THE NAV TITLE
                Section{
                    VStack{
                        HStack{
                            Text("Enter a Title: *")
                            //.fontWeight(.bold)
                            Spacer()
                        }
                        TextField("Title", text: $name)
                            .foregroundColor(secondColor)
                        
                    }
                }
*/
                Section("Daily Notifications"){
                    DatePicker("Select A Time To Be Reminded To Reflect",selection: $notificationH, displayedComponents: .hourAndMinute)
                    
                    Toggle(isOn: $sendNot){
                        Text("Send Daily Notifications")
                    }
                }
                Section("Show Prompts"){
                    Toggle(isOn: $showP){
                        Text("Show Prompts When Creating A New Reflection")
                    }
                }
            
                Section{
                    Button("Purchase Pro"){
                        setsub = true
                        defaults.set(false, forKey: "warn")
                    }
                    .foregroundColor(Color(UIColor.systemBlue))
                    Button("Restore Purchases"){
                        alertV = true
                    }
                    //adapted from https://www.hackingwithswift.com/quick-start/swiftui/how-to-show-an-alert
                    .alert("Restoring Purchases", isPresented: $alertV){
                        Button("Okay", role: .cancel){
                            print(defaults.bool(forKey: "pro"))
                        }
                    }
                    .foregroundColor(Color.blue)
                    .onTapGesture {
                        
                        //revcat
                        Purchases.shared.restorePurchases { (customerInfo, error) in
                            if customerInfo?.entitlements.all["Pro"]?.isActive == true {
                                defaults.set(true, forKey: "pro")
                            }else{
                                defaults.set(false, forKey: "pro")
                            }
                        }
                        
                    }
                    Button("Check For Pro"){
                        if(defaults.bool(forKey: "pro") == true){
                            tex = "You Are A Pro Member"
                        }else{
                            tex = "You Are Not Yet A Pro Member"
                        }
                        alertProList = true
                    }
                    .foregroundColor(Color.blue)
                    .alert(tex, isPresented: $alertProList){
                        Button("Okay", role: .cancel){}
                    }
                }header: {
                    Text("The Pro Zone")
                }footer: {
                    Text("If you paid for Pro on another device and are not recieving your Pro features, click on \"Restore Purchases\"")
                }
                
                
                Section("Support"){
                    Button("Privacy Policy"){
                        let urlP = URL(string: "https://justpaste.it/4ddk7")
                        UIApplication.shared.open(urlP!)
                    }.foregroundColor(Color.blue)
                    Button("EULA"){
                        let urlE = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")
                        UIApplication.shared.open(urlE!)
                    }.foregroundColor(Color.blue)
                    Button("Contact Us"){
                        let urlC = URL(string: "https://www.reddit.com/r/Reflectime/")
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
            .onAppear{
                /*
                setprod()
                print("g")
                 */
            }
            .sheet(isPresented: $setsub){
                subscribeView().presentationDetents([PresentationDetent .large]).interactiveDismissDisabled(true)
            }
            /*
            .toolbar{
                Button("Done", role: .cancel, action: {
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
                    dismiss()
                }).foregroundColor(Color.blue)
                
            }*/
            
        }
        
        .navigationViewStyle(StackNavigationViewStyle())
        
        
    }
    
}
    
    
/*
func showdateF() -> Bool{
    let defaults = UserDefaults.standard
    return defaults.bool(forKey: "showdate")
}
*/
/*
func showIntroF() -> Bool {
    let defaults = UserDefaults.standard
    return defaults.bool(forKey: "showIntro")
}
*/



func setsubF() -> Bool {
    let defaults = UserDefaults.standard
    return defaults.bool(forKey: "sub")
}
/*
func setprod(){
    let defaults = UserDefaults.standard
    var currentOffering: Offering?
    Purchases.shared.getOfferings { offering, error  in
        if let offer = offering?.current{
            currentOffering = offer
        }
    }
    defaults.set(currentOffering!, forKey: "prod")
    print("good")
}*/

func notificationStatus() -> Bool{
    let defaults = UserDefaults.standard
    //print(defaults.bool(forKey: "authorized"))
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
