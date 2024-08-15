//
//  SignUpView.swift
//  SHEUNGKIT_Parking
//
//  Created by Simon Chan on 2024-07-09.
//

import SwiftUI

struct SignUpView: View {
    
    @State private var email : String = ""
    @State private var password : String = ""
    @State private var confirmPassword : String = ""
    @State private var name : String = ""
    @State private var contactNum : String = ""
    @State private var carPlateNum : String = ""
    
    @State private var showAlert: Bool = false
    @State private var message: String = ""
    
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject var fireAuthHelper : FireAuthHelper
    
    @Binding var rootScreen : RootView
    
    var body: some View {
        VStack{
            Text("Join us now!")
                .font(.title)
                .fontWeight(.bold)
            Text("Sign up now to become a member.")
                .font(.headline)
                .fontWeight(.light)
            
            Form{
                TextField("Enter Name", text: self.$name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textInputAutocapitalization(.words)
                    .keyboardType(.default)
                TextField("Enter Email", text: self.$email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                TextField("Enter Password", text: self.$password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textInputAutocapitalization(.never)
                    .keyboardType(.default)
                TextField("Comfirm Password", text: self.$confirmPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textInputAutocapitalization(.never)
                    .keyboardType(.default)
                TextField("Contact Number", text: self.$contactNum)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textInputAutocapitalization(.characters)
                    .keyboardType(.phonePad)
                TextField("Car Plate Number", text: self.$carPlateNum)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textInputAutocapitalization(.characters)
                    .keyboardType(.default)
            }//Form end
            .disableAutocorrection(true)
    
            Button(action: {
                self.createAccount()
            }){
                Text("Create Account")
            }//Button end
            .alert(isPresented: self.$showAlert){
                Alert(title: Text("Error"), message: Text(self.message), dismissButton: .default(Text("Try again"))
                      )
            }
            .buttonStyle(.borderedProminent)
            
            HStack{
                Text("Already a member?")
                Button(action: {
                    self.rootScreen = .SignIn
                }){
                    Text("Login here")
                }
            }
        }//VStack
    }//body
    
    private func createAccount(){
        
        guard self.password == self.confirmPassword else{
            message = "Please enter a correct password"
            showAlert = true
            return
        }
        
        if (self.email.isEmpty || self.password.isEmpty || self.confirmPassword.isEmpty || self.name.isEmpty || self.contactNum.isEmpty || self.carPlateNum.isEmpty) {
            self.message = "All fields are required"
            self.showAlert = true
        } else{
            guard email.contains("@") else{
                showAlert = true
                message = "Please enter a valid email address"
                return
            }
            
            self.fireAuthHelper.signUp(email: self.email, password: self.password, name: self.name, contactNum: self.contactNum, carPlateNum: self.carPlateNum)
            self.rootScreen = .SignIn
            dismiss()
        }
    }
}

