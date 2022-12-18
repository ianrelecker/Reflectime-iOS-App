//
//  NoteAdd.swift
//  ReflectimeV9
//
//  Created by Ian Relecker on 10/29/22.
//

import SwiftUI
import MapKit
import RevenueCat


struct NoteAdd: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: []) var reflections: FetchedResults<Reflection>
    
    @FetchRequest(sortDescriptors: []) var motivations: FetchedResults<Motivations>
    
    

    
    
    let defaults = UserDefaults.standard
    @Environment(\.dismiss) var dismiss
    private let locationAddH = locationHandler()
    
    @State private var name = ""
    @State private var data = "Thought\n \n \n \n"
    @State private var firsttap = false
    @State private var date = Date()
    @State private var includeLocation = true
    
    @State private var cat = "General"
    var cats = ["General", "Personal", "Work", "Feelings", "Wishes", "Intrests"]
    
    @State private var lat = 0.0
    @State private var lon = 0.0
    
    //@State private var idea = gimmePrompt() ?? "Click Shuffle to get a new prompt"
    @State private var showLoc = locationHandler.share.user
    @State private var colortext = Color(UIColor.systemGray4)
    @State private var secondColor = Color("Background")
    
    @State private var idea = ""
    
    var body: some View{
        
        NavigationView{

                ZStack{
                    Form{
                        //change to show edit warning
                        //if(defaults.bool(forKey: "showP")){}
                            Section{
                                VStack{
                                    HStack{
                                        Text("Prompt:")
                                        //.padding(1)
                                            .foregroundColor(Color("Background"))
                                            .fontWeight(.bold)
                                        Spacer()
                                    }
                                    HStack{
                                        
                                        
                                        Text(idea)
                                            .fontWeight(.light)
                                            .foregroundColor(Color("Background"))
                                        
                                        Spacer()
                                        ZStack{
                                            Rectangle()
                                                .frame(width: 40, height: 40)
                                                .foregroundColor(Color(UIColor.lightGray))
                                                .cornerRadius(10)
                                                .onTapGesture {
                                                    idea = gimmePrompt()
                                                }
                                            Image(systemName: "shuffle")
                                                .onTapGesture {
                                                    idea = gimmePrompt()
                                                }
                                        }.frame(width: 40, height: 40, alignment: .trailing)
                                    }
                                    
                                }
                            }
                        
                        Section{
                            VStack{
                                HStack{
                                    Text("Enter a Title: *")
                                    //.fontWeight(.bold)
                                    Spacer()
                                }
                                TextField("Title", text: $name)
                                    .foregroundColor(secondColor)
                                    .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 10))
                                    .border(Color("Background"), width: 1)
                                    .cornerRadius(2)
                                
                            }
                            
                            
                            VStack{
                                HStack{
                                    Text("Enter your Thoughts: *")
                                        .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
                                    //.fontWeight(.bold)
                                    Spacer()
                                }
                                TextEditor(text: $data)
                                    .frame(minHeight: 30, alignment: .leading)
                                    .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 10))
                                    .border(Color("Background"), width: 1)
                                    .cornerRadius(2)
                                
                                    .foregroundColor(colortext)
                                
                                    .onTapGesture {
                                        if(firsttap == false){
                                            data = ""
                                            firsttap = true
                                            colortext = secondColor
                                        }
                                    }
                                Spacer()
                            }
                            Section{
                                Picker(selection: $cat, label: Text("Choose a Catagory").fontWeight(.light)) {
                                    ForEach(cats, id: \.self){
                                        Text($0)
                                    }
                                }
                                
                                if((showLoc) != nil){
                                    Toggle(isOn: $includeLocation) {
                                        Text("Do you want to include your location?").fontWeight(.light)
                                    }
                                }else{
                                    Text("Enable location permissions under the \"Gear\" icon to add your location to a Reflection")
                                        .fontWeight(.light)
                                        .foregroundColor(Color(UIColor.darkGray))
                                        .padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 0))
                                    
                                }
                                HStack{
                                    if(defaults.bool(forKey: "showP")){
                                        NavigationLink{
                                            PromptView()
                                        } label: {
                                            Text("Click Here To Customize Your Prompts!")
                                                .foregroundColor(Color.blue)
                                                .fontWeight(.light)
                                        }
                                                
                                        
                                    }
                                }
                            }
                        }
                    }//form
                    .onAppear{
                        
                    }
                }//z
            .background(Color("BackColor"))
            .navigationTitle("Add a Reflection")
            
            
            .toolbar{
                Button("Cancel", role: .cancel, action: {
                    dismiss()
                }).foregroundColor(.red)
                Button("Save"){
                    if(includeLocation){
                        (lat, lon) = locationAddH.getuser()
                    }
                    let con = Reflection(context: moc)
                    con.id = UUID()
                    con.name = name
                    con.cata = cat
                    con.note = data
                    con.lat = lat
                    con.lon = lon
                    con.date = Date()
                    
                    try? moc.save()
                    dismiss()
                }
                .disabled(savedis())
                .foregroundColor(saveCol())
            }//end tool
            
        }
        .onAppear{
                idea = gimmePrompt()
        }//end nav
        
        
    }//end some view
    
    func gimmePrompt() -> String {
        var motivation = [String]()
        for mot in motivations{
            motivation.append(mot.item ?? "Fail append")
        }
        motivation.shuffle()
        return motivation[0]
    }
    
    func saveCol() -> Color{
        if(savedis()){
            return Color(UIColor.systemGray4)
        }else{
            return Color(UIColor.systemBlue)
        }
    }
    
    func savedis() -> Bool{
        if(data == "Thought\n \n \n \n" || name == ""){
            return true
        }else{
            return false
        }
    }
}//end view

struct Previews_NoteAdd_Previews: PreviewProvider {
    static var previews: some View {
        NoteAdd()
    }
}
