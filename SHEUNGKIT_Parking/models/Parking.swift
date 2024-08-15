//
//  Parking.swift
//  SHEUNGKIT_Parking
//
//  Created by Simon Chan on 2024-07-09.
//

import Foundation
import FirebaseFirestoreSwift

struct Parking : Hashable, Codable{
    @DocumentID var id : String? = UUID().uuidString
 
    var buildingCode : String
    var hour : String
    var carLicense : String
    var suitNum : String
    var location : String
    var lat : Double
    var lng : Double
    var date : Date = Date()
    
    init(buildingCode: String, hour: String, carLicense: String, suitNum: String, location: String, lat: Double, lng: Double) {
        self.buildingCode = buildingCode
        self.hour = hour
        self.carLicense = carLicense
        self.suitNum = suitNum
        self.location = location
        self.lat = lat
        self.lng = lng
    }
}
