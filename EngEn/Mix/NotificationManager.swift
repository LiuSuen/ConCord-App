//
//  Notification.swift
//  EngEn
//
//  Created by dc on 4/7/23.
//


import SwiftUI
import CoreLocation
import UserNotifications
import CoreData

class NotificationManager: NSObject, CLLocationManagerDelegate, ObservableObject, UNUserNotificationCenterDelegate {

    private let locationManager = CLLocationManager()
    @Published var userLocation: CLLocation?
    @Published var contacts: [Contacts]
    private let distanceThreshold: Double = 100000.0 // 100 km in meters
    private var notifiedContacts: Set<String> = []
    
    init(contacts: [Contacts]) {
        self.contacts = contacts
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        UNUserNotificationCenter.current().delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.last else { return }
        userLocation = latestLocation
        fetchUpdatedContacts()
        
        var contact_list: [Contacts] = []
        var push = false
        var city = ""
        for contact in contacts {
            if contact.lastName != nil{
                
                if notifiedContacts.contains(contact.lastName! + contact.firstName!) {
                    continue
                }
                
                let cityCoordinates = searchCity(city: contact.city!, country: contact.country!, state: contact.state!)
                if cityCoordinates == []{
                    let contactLocation = CLLocation(latitude: contact.lat, longitude: contact.lng)
                    let distance = latestLocation.distance(from: contactLocation)
                    
                    if distance <= distanceThreshold {
                        notifiedContacts.insert(contact.lastName!+contact.firstName!)
                        city = contact.city! + contact.state! + contact.country!
                        push = true
                    }
                }
                else{
                    let contactLocation = CLLocation(latitude: cityCoordinates[0].lat, longitude: cityCoordinates[0].lng)
                    let distance = latestLocation.distance(from: contactLocation)
                    
                    if distance <= distanceThreshold {
                        notifiedContacts.insert(contact.lastName!+contact.firstName!)
                        city = contact.city! + contact.state! + contact.country!
                        push = true
                    }
                }
            }
        }
        if push{
            
            for i in contacts{
                if i.city!.trimmingCharacters(in: .whitespaces) + i.state!.trimmingCharacters(in: .whitespaces) + i.country!.trimmingCharacters(in: .whitespaces) == city.trimmingCharacters(in: .whitespaces){
                    contact_list.append(i)
                }
            }
            sendNotification(contact_list: contact_list)
        }
            
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
    }
    
   func sendNotification(contact_list:[Contacts]) {
       let content = UNMutableNotificationContent()
       if contact_list.count == 1{
           content.body = "1 friend near your location:\n"
       }
       else{
           content.body = "\(contact_list.count) friends near your location:\n"
       }
       for i in contact_list{
           content.body += "\(i.city!), \(i.state!), \(i.country!)"
           break
       }
        content.title = "You are close to your friends!"
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error sending notification: \(error.localizedDescription)")
            } else {
                print("Notification sent successfully!")
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Specify the presentation options for the notification
        completionHandler([.banner, .sound])
    }
    func fetchUpdatedContacts() {
        let request = NSFetchRequest<Contacts>(entityName: "Contacts")
        request.sortDescriptors = []
        if let fetchedContacts = try? PersistenceController.shared.container.viewContext.fetch(request) {
            DispatchQueue.main.async {
                self.contacts = fetchedContacts
            }
        }
    }

}
