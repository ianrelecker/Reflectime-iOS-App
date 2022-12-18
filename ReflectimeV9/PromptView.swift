//
//  PromptView.swift
//  ReflectimeV9
//
//  Created by Ian Relecker on 12/17/22.
//

import SwiftUI

struct PromptView: View {

    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "date", ascending: false)]) var motivations: FetchedResults<Motivations>
    
    
    @State private var motivateAdd = ""

    
    var body: some View {
        List(){
            
            Section("Enter your new Prompt here:"){
                HStack{
                    TextField("Prompt:", text: $motivateAdd)
                    Spacer()
                    Image(systemName: "plus")
                        .onTapGesture {
                            if(motivateAdd != ""){
                                let con = Motivations(context: moc)
                                con.item = motivateAdd
                                con.date = Date()
                                motivateAdd = ""
                                try?moc.save()
                            }
                        }
                    
                }
            }
            ForEach(motivations){ mote in
                Text(mote.item ?? "f")
            }.onDelete(perform: removeItems)
        }
        .toolbar{
            EditButton()
        }
    }
    func removeItems(offsets: IndexSet) {
        for offset in offsets{
            let motivate = motivations[offset]
            moc.delete(motivate)
            try?moc.save()
            
        }
        
    }
}

struct PromptView_Previews: PreviewProvider {
    static var previews: some View {
        PromptView()
    }
}
