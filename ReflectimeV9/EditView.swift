//
//  EditView.swift
//  ReflectimeV9
//
//  Created by Ian Relecker on 12/3/22.
//

import SwiftUI

struct EditView: View {

    let reflection: Reflection
    @Environment(\.managedObjectContext) var moc
        
    @Environment(\.dismiss) var dismiss
    private let locationAddH = locationHandler()
    
    @State private var firsttap = false
    @State private var includeLocation = false
    var cats = ["General", "Personal", "Work", "Feelings", "Wishes", "Intrests"]
    
    @State private var triggerchange = false
    
    @State private var name = ""
    @State private var note = ""
    @State private var cata = ""
    
    @State private var showLoc = locationHandler.share.user
    @State private var colortext = Color(UIColor.systemGray4)
    @State private var secondColor = Color("Background")
        
        
    var body: some View {
            NavigationView{

                    ZStack{
                        Form{
                            Section{
                                VStack{
                                    HStack{
                                        Text("Enter a Title:")
                                            .padding(EdgeInsets(top: 4, leading: 0, bottom: 10, trailing: 0))
                                            .fontWeight(.light)
                                        Spacer()
                                    }
                                    TextField("Title", text: $name)
                                        .foregroundColor(Color(UIColor.systemGray))
                                        .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 10))
                                        .border(Color("Background"), width: 1)
                                        .cornerRadius(2)
                                        .frame(height: 20)
                                    Spacer()
                                }
                                    
                                
                                VStack{
                                    HStack{
                                        Text("Enter your Thoughts:")
                                            .padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0))
                                            .fontWeight(.light)
                                        Spacer()
                                    }
                                    TextEditor(text: $note)
                                        //.frame(minHeight: 30, alignment: .leading)
                                        .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 10))
                                        .frame(height: 100)
                                        .border(Color("Background"), width: 1)
                                        .cornerRadius(2)
                                        .foregroundColor(Color(UIColor.systemGray))
                                        
                                    
    
                                    Spacer()
                                }
                                Picker(selection: $cata, label: Text("Choose A Catagory").fontWeight(.light)) {
                                    ForEach(cats, id: \.self){
                                        Text($0)
                                    }
                                }
                                Toggle(isOn: $includeLocation){
                                    let tex = "(Cannot Be Undone.)"
                                    Text("Remove The Location from this Reflection? \(Text(tex).foregroundColor(Color.red))")
                                        .fontWeight(.light)
                                }
                                
                                
                            
                            }
                        }//form
                    }//z
                .background(Color("BackColor"))
                .navigationTitle("Edit Reflection")
                
                .toolbar{
                    Button("Cancel", role: .cancel, action: {
                        dismiss()
                    }).foregroundColor(.red)
                    Button("Save"){
                        if(!includeLocation){
                            reflection.lat = 0.0
                            reflection.lon = 0.0
                        }
                        reflection.name = name
                        reflection.note = note
                        reflection.cata = cata
                        try? moc.save()
                        
                        dismiss()
                        
                            
                    }
                    .foregroundColor(Color.blue)
                    
                }//end tool
                
            }//end nav
            .onAppear{
                if(!triggerchange){
                    name = reflection.name ?? ""
                    cata = reflection.cata ?? ""
                    note = reflection.note ?? ""
                    if(reflection.lat != 0){
                        includeLocation = true
                    }else{
                        includeLocation = false
                        
                    }
                    triggerchange = true
                }
            }
        }//end some view
        
    }//end view

