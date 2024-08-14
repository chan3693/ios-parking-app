//
//  NewParkingView.swift
//  SHEUNGKIT_Parking
//
//  Created by Simon Chan on 2024-07-09.
//

import SwiftUI

struct NewParkingView: View {
    
    @State private var buildingCode : String = ""
    @State private var hour : String = ""
    @State private var carLicense : String = ""
    @State private var suitNum : String = ""
    @State private var location : String = ""
    
    @State private var lat : Double = 0.0
    @State private var lng : Double = 0.0
    
    @State private var showAlert: Bool = false
    @State private var message: String = ""
    
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject var fireDBHelper  : FireDBHelper
    @EnvironmentObject var locationHelper : LocationHelper
    
    var body: some View {
        VStack{
            Spacer()
            Text("New Parking")
                .font(.title)
                .fontWeight(.bold)
            Form{
                TextField("Enter Building code (exactly 5 alphanumeric characters)", text: self.$buildingCode)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textInputAutocapitalization(.characters)
                    .keyboardType(.default)
                    .onChange(of: buildingCode) { newValue in
                        let filtered = newValue.filter {$0.isLetter || $0.isNumber}
                        if filtered.count > 5 {
                            buildingCode = String(filtered.prefix(5))
                        }else{
                            buildingCode = filtered
                        }
                    }
                
                Picker("No. of hours intended to park (1-hour or less, 4-hour, 12-hour, 24-hour)", selection: self.$hour){
                    Text("1-hour").tag("1")
                    Text("4-hour").tag("4")
                    Text("12-hour").tag("12")
                    Text("24-hour").tag("24")
                }
                .pickerStyle(SegmentedPickerStyle())
                
                TextField("Car License Plate Number (min 2, max 8 alphanumeric characters)", text: self.$carLicense)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textInputAutocapitalization(.characters)
                    .keyboardType(.default)
                    .onChange(of: carLicense) { newValue in
                        let filtered = newValue.filter {$0.isLetter || $0.isNumber}
                        if filtered.count > 8 {
                            carLicense = String(filtered.prefix(8))
                        }else{
                            carLicense = filtered
                        }
                    }
                
                TextField("Suit no. of host (min 2, max 5 alphanumeric characters)", text: self.$suitNum)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textInputAutocapitalization(.characters)
                    .keyboardType(.default)
                    .onChange(of: suitNum) { newValue in
                        let filtered = newValue.filter {$0.isLetter || $0.isNumber}
                        if filtered.count > 5 {
                            suitNum = String(filtered.prefix(5))
                        }else{
                            suitNum = filtered
                        }
                    }
                
                TextField("Parking location (street address, lat and lng)", text: self.$location)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textInputAutocapitalization(.never)
                    .keyboardType(.default)
                
                Button(action: {
                    self.locationHelper.getCurrLocation()
                    self.location = locationHelper.location
                }){
                    Text("Use current location")
                }
            }//Form end
            
            Button(action: {
                self.addNewParking()
            }){
                Text("Add Parking")
            }
            .alert(isPresented: self.$showAlert){
                Alert(title: Text("Error"), message: Text(self.message), dismissButton: .default(Text("Try again"))
                      )
            }
            .buttonStyle(.borderedProminent)
        }//VStack
        .onAppear{
            locationHelper.checkPermission()
        }
    }//body
    
    private func addNewParking(){
        if (self.buildingCode.isEmpty || self.hour.isEmpty || self.carLicense.isEmpty || self.suitNum.isEmpty || self.location.isEmpty){
            self.message = "All fields are required"
            self.showAlert = true
        }else{
            if buildingCode.count < 5 {
                showAlert = true
                message = "Please enter exactly 5 alphanumeric characters in Building code"
            } else if carLicense.count < 2 {
                showAlert = true
                message = "Please enter min 2, max 8 alphanumeric characters in Car License Plate Number"
            } else if suitNum.count < 2 {
                showAlert = true
                message = "please enter min 2, max 5 alphanumeric characters in Suit no. of host"
            } else {
                guard !fireDBHelper.parkingList.contains(where: {$0.carLicense == self.carLicense}) else {
                    showAlert = true
                    message = "Plesae add parking with a different car plate"
                    return
                }
                        
                self.locationHelper.performForwardGeocoding(address: self.location) { success in
                    if success{
                        let newParking = Parking(buildingCode: self.buildingCode, hour: self.hour, carLicense: self.carLicense, suitNum: self.suitNum, location: self.location, lat: locationHelper.lat, lng: locationHelper.lng)
                        self.fireDBHelper.insertParking(newParking: newParking)
                        dismiss()
                    }else{
                        self.message = "Failed to get coordinates for location"
                        self.showAlert = true
                    }
                }
            }
        }
    }
}
