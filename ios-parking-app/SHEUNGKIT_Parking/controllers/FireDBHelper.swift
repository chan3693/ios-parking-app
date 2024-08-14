//
//  FireDBHelper.swift
//  SHEUNGKIT_Parking
//
//  Created by Simon Chan on 2024-07-09.
//

import Foundation
import FirebaseFirestore

class FireDBHelper : ObservableObject{
    
    @Published var parkingList = [Parking]()
    
    private static var shared : FireDBHelper?
    
    private let db : Firestore
    
    private let COLLECTION_USER : String = "User_Collection"
    private let COLLECTION_CAR_PLATES: String = "Car_Plates"
    private let COLLECTION_PARKING : String = "Parking_Collection"
    
    private let FIELD_BUILDINGCODE : String = "buildingCode"
    private let FIELD_HOUR : String = "hour"
    private let FIELD_CARLICENSE : String = "carLicense"
    private let FIELD_SUITNUM : String = "suitNum"
    private let FIELD_LOCATION : String = "location"
    
    init(db : Firestore){
        self.db = db
    }
    
    static func getInstance() -> FireDBHelper{
        if (shared == nil){
            shared = FireDBHelper(db: Firestore.firestore())
        }
        return shared!
    }
    
    func getAllPraking(){
        let loggedInUserEmail = UserDefaults.standard.string(forKey: "KEY_EMAIL") ?? ""
        
        print(#function, "loggedInUSerEmail : \(loggedInUserEmail)")
        
        if (loggedInUserEmail.isEmpty){
            print(#function, "No logged in user")
        }else{
            
            do{
                
                self.db
                    .collection(COLLECTION_USER)
                    .document(loggedInUserEmail)
                    .collection(COLLECTION_PARKING)
                    .addSnapshotListener({ (querySnapshot, error) in
                        guard let snapshot = querySnapshot else{
                            print(#function, "No result received from firestore : \(error)")
                            return
                        }
                        snapshot.documentChanges.forEach{ (docChange) in
                            do{                                print(#function, "docChange : \(docChange)")
                                print(#function, "docChange.document : \(docChange.document)")
                                print(#function, "docChange.document.data() : \(docChange.document.data())")
                                print(#function, "docChange.document.documentID : \(docChange.document.documentID)")
                                
                                var parking : Parking = try docChange.document.data(as: Parking.self)
                                
                                parking.id = docChange.document.documentID
                                
                                print(#function, "Parking : \(parking)")
                                
                                let matchedIndex = self.parkingList.firstIndex(where: {( $0.id?.elementsEqual(parking.id!) )! })
                                
                                switch(docChange.type){
                                case .added:
                                    print(#function, "Document added : \(docChange.document.documentID) (\(parking.buildingCode)")
                                    
                                    if (matchedIndex == nil){
                                        self.parkingList.append(parking)
                                    }
                                case .modified:
                                    print(#function, "Document modified : \(docChange.document.documentID) (\(parking.buildingCode)")
                                    
                                    if (matchedIndex != nil){
                                        self.parkingList[matchedIndex!] = parking
                                    }
                                case .removed:
                                    print(#function, "Document deleted : \(docChange.document.documentID) (\(parking.buildingCode)")
                                    if (matchedIndex != nil){
                                        self.parkingList.remove(at: matchedIndex!)
                                    }
                                }
                                
                                
                            }catch let error{
                                print(#function, "Unable to access docment change : \(docChange)")
                            }
                        }
                        
                    })
                
            }catch let error{
                print(#function, "Unable to retrieve the documents from firestore : \(error)")
            }
        }
    }
    
    func insertParking(newParking : Parking){
        let loggedInUserEmail = UserDefaults.standard.string(forKey: "KEY_EMAIL") ?? ""
        
        if (loggedInUserEmail.isEmpty){
            print(#function, "No logged in user")
        }else{
            do{
                
                try self.db
                    .collection(COLLECTION_USER)
                    .document(loggedInUserEmail)
                    .collection(COLLECTION_PARKING)
                    .addDocument(from: newParking)
                
            }catch let error{
                print(#function, "Unable to insert the document to firestore : \(error)")
            }
        }
    }
    
    func updateParking(editParking : Parking){
        let loggedInUserEmail = UserDefaults.standard.string(forKey: "KEY_EMAIL") ?? ""
        
        if (loggedInUserEmail.isEmpty){
            print(#function, "No logged in user")
        }else{
            do{
                self.db.collection(COLLECTION_USER)
                    .document(loggedInUserEmail)
                    .collection(COLLECTION_PARKING)
                    .document(editParking.id!)
                    .updateData(
                        [
                            FIELD_BUILDINGCODE : editParking.buildingCode,
                            FIELD_HOUR : editParking.hour,
                            FIELD_CARLICENSE : editParking.carLicense,
                            FIELD_SUITNUM : editParking.suitNum,
                            FIELD_LOCATION : editParking.location,
                            "lat" : editParking.lat,
                            "lng" : editParking.lng
                        ]
                    ){error in
                        
                        if let err = error {
                            print(#function, "Unable to update document : \(err)")
                        }else{
                            print(#function, "Successfully updated document : \(editParking.id) (\(editParking.buildingCode))")
                        }
                    }
            }catch let error{
                print(#function, "Unable to update the documents from firestore : \(error)")
            }
        }
    }
    
    func deleteParking(parkingToDelete : Parking){
        let loggedInUserEmail = UserDefaults.standard.string(forKey: "KEY_EMAIL") ?? ""
        
        if (loggedInUserEmail.isEmpty){
            print(#function, "No logged in user")
        }else{
            do{
                self.db.collection(COLLECTION_USER)
                    .document(loggedInUserEmail)
                    .collection(COLLECTION_PARKING)
                    .document(parkingToDelete.id!)
                    .delete{ error in
                        
                        if let err = error {
                            print(#function, "Unable to delete document : \(err)")
                        }else{
                            print(#function, "Successfully deleted document : \(parkingToDelete.id) (\(parkingToDelete.buildingCode))")
                        }
                    }
                
            }catch let error{
                print(#function, "Unable to delete the documents from firestore : \(error)")
            }
        }
    }
    
    
}
