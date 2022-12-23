//
//  NotEnoughMapView.swift
//  ReflectimeV9
//
//  Created by Ian Relecker on 12/22/22.
//

import SwiftUI

struct NotEnoughMapView: View {
        @FetchRequest(sortDescriptors: []) var reflections: FetchedResults<Reflection>
        
        
        var body: some View {
            ZStack{
                Image("opaqmap")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .blur(radius: 5)
                    
                Rectangle()
                    .frame(width: 350, height: 75, alignment: .center)
                    .foregroundColor(Color("WB"))
                    .cornerRadius(12)
                    .shadow(radius: 25)
                Text("Not enough Reflections to view.\nYou need \(3 - getNumWithLoc()) more Reflections with\nlocation data to use Map.")
                    .foregroundColor(Color("BW"))
                    .multilineTextAlignment(.center)
                    .dynamicTypeSize(.medium)
                    .fontWeight(.bold)
                    
                
            }
        }
    func getNumWithLoc() -> Int{
        var track = 0
        for ref in reflections{
            if(ref.lat != 0){
                track = track + 1
            }
        }
        return track
    }
}


struct NotEnoughMapView_Previews: PreviewProvider {
    static var previews: some View {
        NotEnoughMapView()
    }
}
