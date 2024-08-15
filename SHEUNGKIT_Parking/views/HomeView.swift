//
//  HomeView.swift
//  SHEUNGKIT_Parking
//
//  Created by Simon Chan on 2024-07-09.
//

import SwiftUI

struct HomeView: View {
    @State private var showNewParkingView : Bool = false
    @State private var selectedIndex : Int = -1
    
    @EnvironmentObject var fireDBHelper : FireDBHelper
    @EnvironmentObject var fireAuthHelper : FireAuthHelper
    @EnvironmentObject var locationHelper : LocationHelper
    
    @Binding var rootScreen : RootView
    
    var body: some View {
        VStack{
            List{
//                .sorted(by: {$0.date > $1.date})
                ForEach(self.fireDBHelper.parkingList.sorted(by: {$0.date > $1.date}).enumerated().map({$0}), id: \.element.self){index, currParking in
                    
                    NavigationLink(destination: DetailView(selectedParkingIndex: index)
                        .environmentObject(self.fireDBHelper)
                        .environmentObject(self.fireAuthHelper)
                        .environmentObject(self.locationHelper)){
                        
                        VStack(alignment: .leading){
                            Text("\(currParking.location)")
                                .fontWeight(.bold)
                            
                            Text("start date : \(currParking.date)")
                                .italic()
                        }//VStack
                        .onTapGesture {
                            self.selectedIndex = index
                            print(#function, "selected parking index : \(self.selectedIndex) \(self.fireDBHelper.parkingList[selectedIndex].location)")
                        }
                    }//NavigationLink
                }//ForEach
                .onDelete(perform: {indexSet in
                    for index in indexSet{
                        let parkingToDelete = self.fireDBHelper.parkingList.sorted(by: {$0.date > $1.date})[index]
                        print(#function, "Parking to delete : \(self.fireDBHelper.parkingList[index].location)")
                        self.fireDBHelper.deleteParking(parkingToDelete: parkingToDelete)
                    }
                })//ondelete
                
            }//List end
            Button(action: {
                self.showNewParkingView = true
            }){
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(Color.blue)
            }
            .sheet(isPresented: self.$showNewParkingView){
                NewParkingView().environmentObject(self.fireDBHelper)
            }
        }
        .toolbar{
            ToolbarItemGroup(placement: .navigationBarTrailing){
                Button{
                    self.fireAuthHelper.signOut()
                    self.rootScreen = .SignIn
                }label: {
                    Text("Sign Out")
                }
            }
        }
        .onAppear(){
            self.fireDBHelper.getAllPraking()
        }
        
    }//body
}
