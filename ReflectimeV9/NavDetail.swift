//
//  NavDetail.swift
//  ReflectimeV9
//
//  Created by Ian Relecker on 11/29/22.
//

import SwiftUI

struct NavDetail: View {
    
    var itemD: NoteItem
    
    var body: some View {
        NavigationLink(destination: NoteDetail(idR: itemD.id, text: itemD.name, data: itemD.data, date: itemD.date, lat: itemD.lat, lon: itemD.lon)){
            HStack{
                VStack{
                    Text(itemD.date.formatted(.dateTime.month(.wide)))
                        .foregroundColor(Color("Background"))
                    
                    Text(itemD.date.formatted(.dateTime.day()))
                        .foregroundColor(Color("Background"))
                        .onAppear{
                            UIApplication.shared.applicationIconBadgeNumber = 0
                        }
                }
                Image(systemName: "poweron")
                    .foregroundColor(Color("Background"))
                    .ignoresSafeArea()
                Text(itemD.name)
                    .foregroundColor(Color("Background"))
                    .onAppear{
                        UIApplication.shared.applicationIconBadgeNumber = 0
                    }
                
            }
            // } for the if show view
        }//end nav
        
    }
}

struct NavDetail_Previews: PreviewProvider {
    static var previews: some View {
        NavDetail(itemD: NoteItem.init(name: "Name", data: "data", date: Date(), lat: 37.0, lon: 120.0, cata: "General"))
    }
}
