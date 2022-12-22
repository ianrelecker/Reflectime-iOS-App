//
//  opaquesortview.swift
//  ReflectimeV9
//
//  Created by Ian Relecker on 12/21/22.
//

import SwiftUI

struct opaquesortview: View {
    
    @FetchRequest(sortDescriptors: []) var reflections: FetchedResults<Reflection>
    
    @Environment(\.dismiss) var dismiss
    
    @State private var showadd = false
    
    var body: some View {
        ZStack{
            Image("opaqsort")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .blur(radius: 5)
                .ignoresSafeArea()
            Rectangle()
                .frame(width: 350, height: 75, alignment: .center)
                .foregroundColor(Color("WB"))
                .cornerRadius(12)
                .shadow(radius: 25)
            Text("Not enough Reflections to reflect on.\nYou need \(3 - reflections.count) more Reflections to use sort.")
                .foregroundColor(Color("BW"))
                .multilineTextAlignment(.center)
                .dynamicTypeSize(.medium)
                .fontWeight(.bold)
                
            
        }.onTapGesture {
            showadd = true
        }
        .sheet(isPresented: $showadd){
            NoteAdd()
        }
    }
}

struct opaquesortview_Previews: PreviewProvider {
    static var previews: some View {
        opaquesortview()
    }
}
