//
//  DetailView.swift
//  SHEUNGKIT_Parking
//
//  Created by Simon Chan on 2024-07-09.
//

import SwiftUI

struct DetailView: View {
    
    let selectedParkingIndex : Int
    
    @State private var buildingCode : String = ""
    @State private var hour : String = ""
    @State private var carLicense : String = ""
    @State private var suitNum : String = ""
    @State private var location : String = ""
    
    @State private var isEdit = false
    
    @State private var showAlert: Bool = false
    @State private var message: String = ""
    
    @EnvironmentObject var fireDBHelper : FireDBHelper
    @EnvironmentObject var locationHelper : LocationHelper
    
    var body: some View {
        NavigationStack{
            VStack{
                Form{
                    if isEdit {
                        TextField("Enter Building Code", text: $buildingCode)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .textContentType(.none)
                            .keyboardType(.default)
                            .onChange(of: buildingCode) { newValue in
                                let filtered = newValue.filter {$0.isLetter || $0.isNumber}
                                if filtered.count > 5 {
                                    buildingCode = String(filtered.prefix(5))
                                }else{
                                    buildingCode = filtered
                                }
                            }
                        
                        Picker("No. of hours intended to park (1-hour or less, 4-hour, 12-hour, 24-hour)", selection: $hour){
                            Text("1-hour").tag("1")
                            Text("4-hour").tag("4")
                            Text("12-hour").tag("12")
                            Text("24-hour").tag("24")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        TextField("Enter Car License Plate Number", text: $carLicense)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .textContentType(.none)
                            .keyboardType(.default)
                            .onChange(of: carLicense) { newValue in
                                let filtered = newValue.filter {$0.isLetter || $0.isNumber}
                                if filtered.count > 8 {
                                    carLicense = String(filtered.prefix(8))
                                }else{
                                    carLicense = filtered
                                }
                            }
                        
                        TextField("Enter Suit Number", text: $suitNum)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .textContentType(.none)
                            .keyboardType(.default)
                            .onChange(of: suitNum) { newValue in
                                let filtered = newValue.filter {$0.isLetter || $0.isNumber}
                                if filtered.count > 5 {
                                    suitNum = String(filtered.prefix(5))
                                }else{
                                    suitNum = filtered
                                }
                            }
                        
                        TextField("Enter Location", text: $location)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .textContentType(.fullStreetAddress)
                            .keyboardType(.default)
                        
                        Button(action: {
                            self.locationHelper.getCurrLocation()
                            self.location = locationHelper.location
                        }){
                            Text("Use current location")
                        }
                    } else {
                        Text("Building code : \(self.fireDBHelper.parkingList[selectedParkingIndex].buildingCode)")
                        Text("No. of hours intended to park : \(self.fireDBHelper.parkingList[selectedParkingIndex].hour)-hour")
                        Text("Car License Plate Number : \(self.fireDBHelper.parkingList[selectedParkingIndex].carLicense)")
                        Text("Suit no. of host : \(self.fireDBHelper.parkingList[selectedParkingIndex].suitNum)")
                        HStack(alignment: .top){
                            Text("Parking location :")
                            Button(action: {
                                if let location = URL(string: "http://maps.apple.com/?address=\(self.fireDBHelper.parkingList[selectedParkingIndex].location)"){
                                    UIApplication.shared.open(location, options: [:], completionHandler: nil)
                                }
                            }){
                                Text(self.fireDBHelper.parkingList[selectedParkingIndex].location)
                            }
                        }
                        Text("Date and time of parking : \(self.fireDBHelper.parkingList[selectedParkingIndex].date)")
                    }
                  
                }//form end
                Button(action: {
                    if isEdit{
                        updateParking()
                    }
                    isEdit = true
                    buildingCode = self.fireDBHelper.parkingList[selectedParkingIndex].buildingCode
                    hour = self.fireDBHelper.parkingList[selectedParkingIndex].hour
                    carLicense = self.fireDBHelper.parkingList[selectedParkingIndex].carLicense
                    suitNum = self.fireDBHelper.parkingList[selectedParkingIndex].suitNum
                    location = self.fireDBHelper.parkingList[selectedParkingIndex].location
                }){
                    Text(isEdit ? "Save Changes" : "Edit Parking")
                }//Button end
                .alert(isPresented: self.$showAlert){
                    Alert(title: Text("Error"), message: Text(self.message), dismissButton: .default(Text("Try again"))
                          )
                }
                .buttonStyle(.borderedProminent)
            }//VStack
        }//NavigationStack
        .navigationTitle(Text("Parking Detail"))
    }//body
    
    
    private func updateParking(){
        if (self.buildingCode.isEmpty || self.hour.isEmpty || self.carLicense.isEmpty || self.suitNum.isEmpty || self.location.isEmpty){
            self.message = "All fields are required"
            self.showAlert = true
        } else{
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
                self.fireDBHelper.parkingList[selectedParkingIndex].buildingCode = self.buildingCode
                self.fireDBHelper.parkingList[selectedParkingIndex].hour = self.hour
                self.fireDBHelper.parkingList[selectedParkingIndex].carLicense = self.carLicense
                self.fireDBHelper.parkingList[selectedParkingIndex].suitNum = self.suitNum
                self.fireDBHelper.parkingList[selectedParkingIndex].location = self.location

                self.locationHelper.performForwardGeocoding(address: self.location) { success in
                
                    if success{
                        self.fireDBHelper.parkingList[selectedParkingIndex].lat = locationHelper.lat
                        self.fireDBHelper.parkingList[selectedParkingIndex].lng = locationHelper.lng
                        
                        self.fireDBHelper.updateParking(editParking: self.fireDBHelper.parkingList[selectedParkingIndex])
                        
                        isEdit = false
                    } else {
                        print(#function, "Failed to get coordinates for location")
                    }
                }
            }
        }
    }
}


