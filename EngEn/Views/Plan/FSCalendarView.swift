//
//  UICalendarView.swift
//  EngEn
//
//  Created by dc on 4/10/23.
//

import SwiftUI
import UIKit
import FSCalendar

struct FSCalendarView: UIViewRepresentable {
    typealias UIViewType = FSCalendar
    @Binding var planItems: [PlanItem]
    @Binding var selectedDateEvents: [PlanItem]
    
    // Create a coordinator for delegate and dataSource methods
    class Coordinator: NSObject, FSCalendarDelegate, FSCalendarDataSource {
        var parent: FSCalendarView
        
        init(_ parent: FSCalendarView) {
            self.parent = parent
        }
        
        func convertDateStringToDate(_ dateString: String) -> Date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd yyyy"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")

            return dateFormatter.date(from: dateString)!
        }
        
        // Implement the required delegate and dataSource methods
        func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
            let calendarDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: date)
            
            let eventsOnDate = parent.planItems.filter { planItem in
                let planItemDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: planItem.beginDate)//convertDateStringToDate(planItem.beginDate)
                return calendarDateComponents == planItemDateComponents
            }
            
            return eventsOnDate.count
        }
        
        func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
                let calendarDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: date)
                
                let eventsOnDate = parent.planItems.filter { planItem in
                    let planItemDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: planItem.beginDate)//convertDateStringToDate(planItem.beginDate)
                    return calendarDateComponents == planItemDateComponents
                }
                
                parent.selectedDateEvents = eventsOnDate
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> FSCalendar {
        let calendar = FSCalendar()
        
        // Setup the calendar appearance, dataSource, and delegate here
        calendar.dataSource = context.coordinator
        calendar.delegate = context.coordinator
        
        return calendar
    }
    
    func updateUIView(_ uiView: FSCalendar, context: Context) {
        // Update the calendar view if needed
        uiView.reloadData()
    }
}


