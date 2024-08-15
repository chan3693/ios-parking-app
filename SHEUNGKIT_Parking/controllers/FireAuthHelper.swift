//
//  FireAuthHelper.swift
//  SHEUNGKIT_Parking
//
//  Created by Simon Chan on 2024-07-09.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class FireAuthHelper : ObservableObject{
    
    private let COLLECTION_USER : String = "User_Collection"
    private let COLLECTION_INFO : String = "Info_Collection"
    
    @Published var user : User?{
        didSet{
            objectWillChange.send()
        }
    }
    
    private static var shared : FireAuthHelper?
    
    static func getInstance() -> FireAuthHelper{
        
        if (shared == nil){
            shared = FireAuthHelper()
        }
        
        return shared!
    }
    
    func listenToAuthState(){
        Auth.auth().addStateDidChangeListener{ [weak self] _, user in
            guard let self = self else{
                return
            }
            self.user = user
            print(#function, "Auth changed : \(user?.email)")
        }
    }

    func signUp(email : String, password : String, name : String, contactNum : String, carPlateNum : String){
        
        Auth.auth().createUser(withEmail: email, password: password){ [self] authResult, error in
            
            guard let result = authResult else{
                print(#function, "Error while creating account : \(error)")
                return
            }
            
            print(#function, "authResult : \(authResult)")
            
            switch authResult{
            case .none:
                print(#function, "Unable to create account : \(authResult?.description)")
            case .some(_):
                print(#function, "Successfully created user account : \(authResult?.description)")
                
                self.user = authResult?.user
                print(#function, "user : \(user?.description)")
//                self.user?
                
                //check if email not nil
                UserDefaults.standard.set(self.user?.email, forKey: "KEY_EMAIL")
                
                let userInfo = UserInfo(name: name, contactNum: contactNum, carPlateNum: carPlateNum)
                let db = Firestore.firestore()
                
                do{
                    try db
                        .collection(COLLECTION_USER)
                        .document(user!.email!)
                        .collection(COLLECTION_INFO)
                        .addDocument(from : userInfo)
                    print(#function, "Successfully added to info collection : \(userInfo.name)")
                }catch let error{
                    print(#function, "Error in adding doc \(error)")
                }
                
                self.resetParkingList()
            }
            
        }
        
    }
    
    func signIn(email : String, password : String, completion: @escaping(_ errorMessage: String?) -> Void){
        Auth.auth().signIn(withEmail: email, password: password){ [self] authResult, error in
            
            guard let result = authResult else{
                print(#function, "Error while signing in : \(error)")
                completion("Wrong email or password.")
                return
            }
            
            print(#function, "authResult : \(authResult)")
            
            switch authResult{
            case .none:
                print(#function, "Unable to sign in : \(authResult?.description)")
                completion("Sign in error.")
            case .some(_):
                print(#function, "Successfully signed in : \(authResult?.description)")
                
                self.user = authResult?.user
                print(#function, "logged in user : \(user?.description)")
                
                UserDefaults.standard.set(email, forKey: "KEY_EMAIL")
                
                self.resetParkingList()
                
                completion(nil)
            }
            
        }
    }
    
    func resetParkingList(){
        FireDBHelper.getInstance().parkingList.removeAll()
        FireDBHelper.getInstance().getAllPraking()
    }
    
    func signOut(){
        do{
            try Auth.auth().signOut()
            self.resetParkingList()
        }catch let error{
            print(#function, "Unable to sign out user : \(error)")
        }
    }
}

