//
//  NotificationHandler.swift
//  ReflectimeV9
//
//  Adapted by Ian Relecker on 11/26/22 from https://youtu.be/mG9BVAs8AIo.
//

import SwiftUI
import UserNotifications

class NotificationClass{
    static let item = NotificationClass()
    
    func requestPermission(){
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: options) {(sucess, error) in
            if let error = error{
                print("error \(error)")
                //notificationStatus.setStatus(false)
            }else{
                //print("yes")
                //notificationStatus.setStatus(true)
            }
        }
    }
    
    
    
    func test(){
        let content = UNMutableNotificationContent()
        content.title = "Title Test"
        content.subtitle = "Subtitle"
        content.sound = .default
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5.0, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger)
       // UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().add(request)
    }
    
    func schedule(dateInput: Date){
        let active = true
        
        let hourI = Calendar.current.dateComponents([.hour], from: dateInput)
        let minuteI = Calendar.current.dateComponents([.minute], from: dateInput)
        var dateComponents = DateComponents()
        dateComponents.hour = hourI.hour
        dateComponents.minute = minuteI.minute
        
        let defaults = UserDefaults.standard
        defaults.set(dateInput, forKey: "Date")
        defaults.set(active, forKey: "authorized")
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        
        let content = UNMutableNotificationContent()
        content.title = "Reflectime"
        content.subtitle = "Now Is The Time To Reflect."
        content.sound = .default
        content.badge = 1
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger)
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().add(request)
        
        if (defaults.bool(forKey: "sendNot") == false){
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        }
    }
}


struct NotificationHandler: View {
    var body: some View {
        VStack{
            
            Button("Request Permission"){
                NotificationClass.item.requestPermission()
            }
            
            
        }
    }
}

struct NotificationHandler_Previews: PreviewProvider {
    static var previews: some View {
        NotificationHandler()
    }
}
