//
//  CalendarView.swift
//  EngEn
//
//  Created by dc on 4/10/23.
//

import SwiftUI

struct CalendarView: View {
    @ObservedObject var planData = PlanData.shared
    @State private var selectedDateEvents: [PlanItem] = []
    

    var body: some View {
        GeometryReader { geometry in
            if selectedDateEvents.count == 0{
                VStack {
                    FSCalendarView(planItems: $planData.planList, selectedDateEvents: $selectedDateEvents)
                    Text("No Event For Selected Date")
                        .padding(.bottom,50)
                }
            }
            else{
                VStack {
                    FSCalendarView(planItems: $planData.planList, selectedDateEvents: $selectedDateEvents)
                    EventsList(events: selectedDateEvents)
                }
            }
            
        }
    }
}


struct EventsList: View {
    var events: [PlanItem]
    var dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            return formatter
        }()
    
    var body: some View {
        ZStack {
            
            List(events) { item in
                HStack{
                    ZStack{
                        HStack{
                            VStack(alignment:.leading) {//to show the planned event of this date
                                HStack{
                                    Text(dateFormatter.string(from: item.beginDate)+"-"+dateFormatter.string(from: item.endDate))
                                        .font(.system(size: 22, design: .rounded))
                                        .bold()
                                        .foregroundColor(Color(red: 0.0, green: 0.2, blue: 0.0))
                                    Spacer()
                                    
                                }
                                Text("\(item.city),\(item.state),\(item.country)")
                                    .font(.system(size: 18, design: .rounded))
                                    .bold()
                                    .foregroundColor(Color(red: 0.0, green: 0.2, blue: 0.0))
                                Text("\(item.peopleList.count) people to visit")
                                    .font(.system(size: 15, design: .rounded))
                                    .foregroundColor(Color(.gray))
                                DisclosureGroup{
                                    VStack(alignment: .leading){
                                        ForEach(item.peopleList, id:\.self){ name in
                                            Text(name).font(.system(size: 15, design: .rounded))
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
                    
                }
                .background(RoundedRectangle(cornerRadius: 12).fill(.white))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
            }
            .listStyle(.insetGrouped)
            
        }
    }
}
