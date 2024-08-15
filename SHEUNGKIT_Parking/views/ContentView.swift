//
//  ContentView.swift
//  SHEUNGKIT_Parking
//
//  Created by Simon Chan on 2024-07-09.
//

import SwiftUI

struct ContentView: View {
    
    var firedbHelper : FireDBHelper = FireDBHelper.getInstance()
    var fireAuthHelper : FireAuthHelper = FireAuthHelper.getInstance()
    var locationHelper : LocationHelper = LocationHelper.getInstance()
    
    @State private var root : RootView = .SignIn
    
    var body: some View {
        NavigationStack{
            switch(root){
            case .SignIn:
                SignInView(rootScreen: self.$root)
                    .environmentObject(fireAuthHelper)
                    .environmentObject(firedbHelper)
                    .environmentObject(locationHelper)
                    .navigationTitle("SHEUNGKIT_Parking")
            case .SignUp:
                SignUpView(rootScreen: self.$root)
                    .environmentObject(fireAuthHelper)
                    .environmentObject(firedbHelper)
                    .environmentObject(locationHelper)
                    .navigationTitle("SHEUNGKIT_Parking")
            case .Home:
                HomeView(rootScreen: self.$root)
                    .environmentObject(fireAuthHelper)
                    .environmentObject(firedbHelper)
                    .environmentObject(locationHelper)
                    .navigationTitle("SHEUNGKIT_Parking")
            }
        }
        
    }
}
