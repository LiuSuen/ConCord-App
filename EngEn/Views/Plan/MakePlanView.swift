//
//  MakePlanView.swift
//  EngEn
//
//  Created by Suen Lau on 2023/4/10.
//

import SwiftUI

struct MakePlanView: View {
    @ObservedObject var planData = PlanData.shared
    @FetchRequest(sortDescriptors: [], animation: .default)
    private var contacts: FetchedResults<Contacts>
    var body: some View {
        
        NavigationView {
            VStack {
                HStack{
                    Text("Plan a trip").font(.system(size: 30, design: .rounded)).bold()
                        .foregroundColor(Color(red: 0.0, green: 0.2, blue: 0.0))
                        .offset(x:10)
                    Spacer()
                }
                .padding(.leading)
                NavigationLink(destination: PlanView()) {
                    Text("Make a Plan")
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                }
                .navigationBarHidden(true)
                .frame(width: 350, height: 40)
                .background(Color.yellow)
                .cornerRadius(10)
                .padding(.bottom)
                
                //to show the plan list
                PlanItemView()
                Spacer()
            }
        }
        
    }
}

struct MakePlanView_Previews: PreviewProvider {
    static var previews: some View {
        MakePlanView()
    }
}
