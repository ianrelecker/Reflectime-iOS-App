//
//  subscribeView.swift
//  ReflectimeV9
//
//  Created by Ian Relecker on 12/5/22.
//  Adapted from https://youtu.be/11A0hUjbCb4
//

import SwiftUI
import RevenueCat

struct subscribeView: View {
    
    @Environment(\.dismiss) var dismiss
    @State private var currentOffering: Offering?
    let defaults = UserDefaults.standard
    
    
    
    var body: some View {
        ZStack{
            Rectangle()
                .foregroundColor(Color("BackColor"))
                .ignoresSafeArea()
            VStack{
                Image("sub")
                    .cornerRadius(30)
                    .imageScale(.small)
                    .onAppear{
                        //revenuecat code
                        
                        Purchases.shared.getOfferings { offering, error  in
                            if let offer = offering?.current{
                                currentOffering = offer
                            }
                        }
                        
                        
                    }
                
                Rectangle()
                    .frame(height: 1, alignment: .center)
                    .foregroundColor(Color("BackColor"))
                    .fixedSize()
                 
                ZStack{
                    Rectangle()
                        .foregroundColor(Color(UIColor.systemGray5))
                        .frame(width: 380, height: 50, alignment: .center)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                    Text("You have reached the limit of free Reflections.\nWith Pro you can make unlimited Refelections.")
                        .foregroundColor(Color.red)
                        .fontWeight(.bold)
                        .frame(width: 380)
                }
                Rectangle()
                    .frame(height: 1, alignment: .center)
                    .foregroundColor(Color("BackColor"))
                    .fixedSize()
                
                ZStack{
                    Rectangle()
                        .frame(width: 380, height: 250, alignment: .center)
                        .foregroundColor(Color.white)
                        //.fixedSize(horizontal: true, vertical: true)
                        .cornerRadius(30)
                    Text("Hi, it's Ian.\nI work to make Reflectime the best it can be.\n\nTo do that I need your support,\nif you find Reflectime useful in any way\nplease consider getting Reflectime Pro.\n\nFor about the price of one coffee pod\nyou can help support me and my family.\nThank you.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color.black)
                }
                .frame(alignment: .center)
                
                Rectangle()
                    .frame(height: 2, alignment: .center)
                    .foregroundColor(Color("BackColor"))
                 
                //revenuecat code
                if(currentOffering != nil){
                    ForEach(currentOffering!.availablePackages.reversed()){ pkg in
                        ZStack{
                            Rectangle()
                                .frame(width: 270, height: 50, alignment: .center)
                                .foregroundColor(Color(UIColor.systemBlue))
                                .cornerRadius(15)
                                .onTapGesture {
                                    dismiss()
                                    
                                    let defaults = UserDefaults.standard
                                    defaults.set(false, forKey: "sub")
                                    defaults.set(true, forKey: "dis")
                                    //revenuecat code
                                    Purchases.shared.purchase(package: pkg) { (transaction, customerInfo, error, userCancelled) in
                                        if customerInfo?.entitlements.all["Pro"]?.isActive == true {
                                            defaults.set(true, forKey: "pro")
                                            print("yay active mem")
                                        }else {
                                            defaults.set(false, forKey: "pro")
                                                print("nay no mem")
                                        }
                                    }
                                    //
                                }
                            VStack{
                                Text("Purchase \(pkg.storeProduct.localizedTitle)\n\(pkg.storeProduct.localizedDescription)")
                                    .foregroundColor(Color.white)
                                    .fontWeight(.bold)
                                    .allowsHitTesting(false)
                                    .multilineTextAlignment(.center)
                            }
                        }
                    }
                }
                Rectangle()
                    .frame(height: 15)
                    .foregroundColor(Color("BackColor"))
                    
                ZStack{
                    Rectangle()
                        .frame(width: 125, height: 40, alignment: .center)
                        .foregroundColor(Color(UIColor.systemGray4))
                        .cornerRadius(10)
                        .onTapGesture {
                            let defaults = UserDefaults.standard
                            defaults.set(false, forKey: "sub")
                            defaults.set(true, forKey: "dis")
                            dismiss()
                            
                        }
                    Text("Cancel")
                        .fontWeight(.ultraLight)
                        .allowsHitTesting(false)
                }
            }
        }
    }
}

struct subscribeView_Previews: PreviewProvider {
    static var previews: some View {
        subscribeView()
    }
}
