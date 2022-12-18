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
    
    @State private var showPay = false
    
    let defaults = UserDefaults.standard

    
    var body: some View {
        List(){
            Section{
                if(defaults.bool(forKey: "pro") == false){
                    HStack{
                        Spacer()
                        ZStack{
                            Rectangle()
                                .frame(width: 340, height: 30, alignment: .center)
                                .foregroundColor(Color("BackColor"))
                                .cornerRadius(10)
                                .shadow(radius: 3)
                                .onTapGesture{
                                    defaults.set(false, forKey: "warn")
                                    showPay = true
                                }
                            Text("You have \(10 - defaults.integer(forKey: "prom")) free custom prompts remaining.")
                                .fixedSize()
                                .fontWeight(.light)
                                .multilineTextAlignment(.center)
                                .dynamicTypeSize(.medium)
                                .allowsHitTesting(false)
                        }
                        Spacer()
                    }
                }
            }
            Section("Enter your new Prompt here:"){
                HStack{
                    TextField("Prompt:", text: $motivateAdd)
                    Spacer()
                    Image(systemName: "plus")
                        .onTapGesture {
                            
                            
                            if(motivateAdd != "" && defaults.bool(forKey: "pro") == true || defaults.integer(forKey: "prom") < 10){
                                
                                let adder = defaults.integer(forKey: "prom")
                                defaults.set(adder + 1, forKey: "prom")
                                
                                let con = Motivations(context: moc)
                                con.item = motivateAdd
                                con.date = Date()
                                motivateAdd = ""
                                try?moc.save()
                            }else{
                                showPay = true
                            }
                        }
                    
                }
            }
            ForEach(motivations){ mote in
                Text(mote.item ?? "f")
            }.onDelete(perform: removeItems)
        }
        .sheet(isPresented: $showPay){
            subscribeView().presentationDetents([PresentationDetent .large])
                .interactiveDismissDisabled(true)
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
