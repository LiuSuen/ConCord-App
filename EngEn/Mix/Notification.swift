//
//  Notification.swift
//  EngEn
//
//  Created by Suen Lau on 2023/4/5.
//

import Foundation
import UserNotifications

func requestNotiPermission() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
        if success {
            print("Push notification allowed.")
        } else {
            //print(error.localizedDescription)
            print("Push notification not allowed.")
        }
    }
}

//func sendNotification(){
//    //set the notification trigger
//    //when user enter certain city
//    //To do
//    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
//
//    var num: Int = 1//to do
//    var city: String = "city name"//to do
//    //To Do:
//    //compare current location with location in database
//    //calculate num and city
//    var be: String = num>1 ? "are": "is"
//
//    //set notification content
//    let content = UNMutableNotificationContent()
//    content.title = "Near contacts"
//    content.body = "There \(be) \(num) contact(s) in \(city). Click to see more."
//    content.sound = UNNotificationSound.default
//
//    let request = UNNotificationRequest(identifier: "NearContacts", content: content, trigger: trigger)
//
//    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
//}

