//
//  UserInfo.swift
//  SHEUNGKIT_Parking
//
//  Created by Simon Chan on 2024-07-09.
//

import Foundation
import FirebaseFirestoreSwift

struct UserInfo : Hashable, Codable{
    @DocumentID var id : String? = UUID().uuidString
    
    var name : String = ""
    var contactNum : String = ""
    var carPlateNum : String = ""
    var date : Date = Date()
    
    init(name: String, contactNum: String, carPlateNum: String) {
        self.name = name
        self.contactNum = contactNum
        self.carPlateNum = carPlateNum
    }
    
}
