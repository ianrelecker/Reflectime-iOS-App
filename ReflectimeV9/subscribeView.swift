//
//  subscribeView.swift
//  ReflectimeV9
//
//  Created by Ian Relecker on 12/5/22.
//  Adapted from https://youtu.be/11A0hUjbCb4
// change

import SwiftUI
import RevenueCat

struct subscribeView: View {
    
    @Environment(\.dismiss) var dismiss
    @State private var currentOffering: Offering?
    let defaults = UserDefaults.standard
    
    @State var alertV = false
    
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
                
                if(defaults.bool(forKey: "warn") == true){
                    ZStack{
                        Rectangle()
                            .foregroundColor(Color(UIColor.systemGray5))
                            .frame(width: 380, height: 50, alignment: .center)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                        Text("You have reached the limit of free uses.")
                            .foregroundColor(Color.red)
                            .fontWeight(.bold)
                            .frame(width: 380)
                            .multilineTextAlignment(.center)
                    }
                }
                Rectangle()
                    .frame(height: 1, alignment: .center)
                    .foregroundColor(Color("BackColor"))
                    .fixedSize()
                
                ZStack{
                    Rectangle()
                        .frame(width: 350, height: 160, alignment: .center)
                        .foregroundColor(Color.white)
                        .fixedSize()
                        .cornerRadius(30)
                        .shadow(radius: 2)
                    Text("Hi, it's Ian.\nI work to make Reflectime the best it can be.\n\nTo do that I need your support,\nplease consider getting Reflectime Pro.\n\nThank you.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color.black)
                }
                .frame(alignment: .center)
                
                Rectangle()
                    .frame(height: 0, alignment: .center)
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
                    .frame(height: 0, alignment: .center)
                    .foregroundColor(Color("BackColor"))
                
                ZStack{
                    Rectangle()
                        .frame(width: 200, height: 40, alignment: .center)
                        .foregroundColor(Color(UIColor.systemGray4))
                        .cornerRadius(15)
                        .alert("Restoring Purchases", isPresented: $alertV){
                            Button("Okay", role: .cancel){
                                print(defaults.bool(forKey: "pro"))
                            }
                        }
                        .onTapGesture {
                            Purchases.shared.restorePurchases { (customerInfo, error) in
                                if customerInfo?.entitlements.all["Pro"]?.isActive == true {
                                    defaults.set(true, forKey: "pro")
                                }else{
                                    defaults.set(false, forKey: "pro")
                                }
                            }
                        }
                    Text("Restore Purchases")
                        .allowsHitTesting(false)
                        .fontWeight(.bold)
                        //.foregroundColor(Color.white)
                }
                
                
                
                ZStack{
                    Rectangle()
                        .frame(width: 100, height: 40, alignment: .center)
                        .foregroundColor(Color(UIColor.systemGray4))
                        .cornerRadius(20)
                        .onTapGesture {
                            let defaults = UserDefaults.standard
                            defaults.set(false, forKey: "sub")
                            defaults.set(true, forKey: "dis")
                            defaults.set(true, forKey: "warn")
                            dismiss()
                            
                        }
                    Text("Cancel")
                        .fontWeight(.light)
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
