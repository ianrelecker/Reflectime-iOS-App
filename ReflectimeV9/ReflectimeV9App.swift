//
//  ReflectimeV9App.swift
//  ReflectimeV9
//
//  Created by Ian Relecker on 10/29/22.
//

import SwiftUI
import RevenueCat

@main
struct ReflectimeV9App: App {
    @StateObject private var dataController = DataController()
    
    var body: some Scene {
        WindowGroup {
            TabsView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
        }
    }
    init() {
        
        
        
        //rev cat code
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: "appl_QlJQRSJGsQftOnEdMzVzhdUSQlq")
        let defaults = UserDefaults.standard
        Purchases.shared.restorePurchases { (customerInfo, error) in
            if customerInfo?.entitlements.all["Pro"]?.isActive == true {
                defaults.set(true, forKey: "pro")
            }else{
                defaults.set(false, forKey: "pro")
            }
        }
        //
    }
}
