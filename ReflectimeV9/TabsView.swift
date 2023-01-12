//
//  TabsView.swift
//  ReflectimeV9
//
//  Created by Ian Relecker on 12/8/22.
//

import SwiftUI

struct TabsView: View {
    var body: some View {
        VStack{
            
                TabView{
                    
                    ContentView()
                        .tabItem({
                            Image(systemName: "house")
                            Text("Home")
                        })
                    CalendarView()
                        .tabItem({
                            Image(systemName: "brain.head.profile")
                            Text("Reflect")
                        })
                    /*
                    MapViewAll()
                        .tabItem({
                            Image(systemName: "map")
                            Text("Map")
                        })
                     */
                    SettingsView()
                        .tabItem({
                            Image(systemName: "gear")
                            Text("Settings")
                            
                        })
                    
                    
                }.tableStyle(.inset)
                
            
            
        }
    }
}

struct TabsView_Previews: PreviewProvider {
    static var previews: some View {
        TabsView()
    }
}
