//
//  PlanItemView.swift
//  EngEn
//
//  Created by Suen Lau on 2023/4/10.
//

import SwiftUI

struct PlanItemView: View {
    @ObservedObject var planData = PlanData.shared
    var body: some View {
        List{
            ForEach(planData.planList){ item in
                PlanItemRowView(item: item)
            }
            .background(RoundedRectangle(cornerRadius: 12).fill(.white))
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
        }
        .listStyle(.insetGrouped)
    }
}

struct PlanItemView_Previews: PreviewProvider {
    static var previews: some View {
        PlanItemView()
    }
}

struct PlanItemRowView: View {
    @ObservedObject var planData = PlanData.shared
    var item: PlanItem
    var dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            return formatter
        }()
    var body: some View {
        ZStack{
            HStack{
                VStack(alignment:.leading) {
                    HStack{
                        Text(dateFormatter.string(from: item.beginDate)+"-"+dateFormatter.string(from: item.endDate))
                            .font(.system(size: 24, design: .rounded))
                            .bold()
                            .foregroundColor(Color(red: 0.0, green: 0.2, blue: 0.0))
                        Spacer()
                        
                    }
                    Text("\(item.city),\(item.state),\(item.country)")
                        .font(.system(size: 20, design: .rounded))
                        .bold()
                        .foregroundColor(Color(red: 0.0, green: 0.2, blue: 0.0))
                    Text("\(item.peopleList.count) people to visit")
                        .font(.system(size: 15, design: .rounded))
                        .foregroundColor(Color(.gray))
                    DisclosureGroup{//to show the detailed contact list
                        VStack(alignment: .leading){
                            ForEach(item.peopleList, id:\.self){ name in
                                Text(name).font(.system(size: 15, design: .rounded)).bold()
                                Divider()
                            }
                        }
                    }label: {
                            Text("See detail")
                                .foregroundColor(Color(red: 0.0, green: 0.2, blue: 0.0))
                            .font(.system(size: 15, weight: .light, design: .rounded))}
                    //.padding()
                }
                .padding(.leading)
                Spacer()
            }
        }
        .padding()
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button {
                self.planData.deletePlan(item: item)
            } label: {
                Label("Delete", systemImage: "trash")
            }
            .tint(.red)
        }
    }
    
}
