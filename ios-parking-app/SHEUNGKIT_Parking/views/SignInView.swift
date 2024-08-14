//
//  SignInView.swift
//  SHEUNGKIT_Parking
//
//  Created by Simon Chan on 2024-07-09.
//

import SwiftUI

struct SignInView: View {
    
    @State private var email : String = ""
    @State private var password : String = ""
    
    @State private var showAlert: Bool = false
    @State private var message: String = ""
    
    @EnvironmentObject var fireAuthHelper : FireAuthHelper
    
    @Binding var rootScreen : RootView
    
    var body: some View {
        VStack{
                        Text("Welcome back!")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("Login to access your account.")
                            .font(.headline)
                            .fontWeight(.light)
            Form{
                TextField("Enter Email", text: self.$email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                SecureField("Enter Password", text: self.$password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textInputAutocapitalization(.never)
                    .keyboardType(.default)
            }//Form ends
            .disableAutocorrection(true)
            
            Button(action: {
                self.login()
            }){
                Text("Sign In")
            }
            .alert(isPresented: self.$showAlert){
                Alert(title: Text("Error"), message: Text(self.message), dismissButton: .default(Text("Try again"))
                      )
            }
            .buttonStyle(.borderedProminent)
            
            HStack{
                Text("Not a member?")
                Button(action: {
                    self.rootScreen = .SignUp
                }){
                    Text("Sign Up here")
                }
            }
        }//VStack ends
    }//body
    
    private func login(){
        
//        guard self.email == fireAuthHelper.
        guard !self.email.isEmpty && !self.password.isEmpty else{
            message = "Please enter your email and password"
            showAlert = true
            return
        }
        
        self.fireAuthHelper.signIn(email: self.email, password: self.password) { errorMessage in
            if let errorMessage = errorMessage {
                message = errorMessage
                showAlert = true
                return
            }
            self.rootScreen = .Home
        }
    }
}
