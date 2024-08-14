//
//  SHEUNGKIT_ParkingApp.swift
//  SHEUNGKIT_Parking
//
//  Created by Simon Chan on 2024-07-09.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

@main
struct SHEUNGKIT_ParkingApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
