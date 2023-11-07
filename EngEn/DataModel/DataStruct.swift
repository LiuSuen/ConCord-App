//
//  DataStruct.swift
//  EngEn
//
//  Created by Loaner on 3/21/23.
//

import Foundation
import CoreData
import SwiftUI
import MapKit
import Contacts

class ContactsData: ObservableObject {
    let context = PersistenceController.shared.container.viewContext
    
    @Published var contacts = [Contacts]()
    
    init() {
        importJsonConData()
        fetchContacts()
    }
    
    func fetchContacts() {
        let request: NSFetchRequest<Contacts> = Contacts.fetchRequest()
        
        do {
            contacts = try context.fetch(request)
        } catch let error {
            print("Error fetching contacts: \(error.localizedDescription)")
        }
    }
    
    func toggleToVisit(contact: Contacts) {
        contact.tovisit.toggle()
        saveContext()
    }
    
    func saveContext() {
        do {
            try context.save()
        } catch let error {
            print("Error saving context: \(error.localizedDescription)")
        }
    }
}

class GeoData: ObservableObject {
    let context = PersistenceController.shared.container.viewContext
    
    @Published var cities = [City]()
    
    init() {
        loadJsonGeoData()
        fetchCity()
    }
    
    func fetchCity() {
        let request: NSFetchRequest<City> = City.fetchRequest()
        
        do {
            cities = try context.fetch(request)
        } catch let error {
            print("Error fetching contacts: \(error.localizedDescription)")
        }
    }
}

struct NewContactData {
    var firstName: String?
    var lastName: String?
    var city: String?
    var state: String?
    var country: String?
    var picture: UIImage?
    var email: String?
    var phone: String?
    var notes: String?
    var lat: Double
    var lng: Double
}
// Address Data Model
struct Address: Codable {
   let data: [Datum]
}

struct Datum: Codable {
   let latitude, longitude: Double
   let name: String?
    let region: String?
    let country: String?
}

// Our Pin Locations
struct Location: Identifiable {
    let id = UUID()
    let name: String
    let region: String
    let country: String
    let latitude: Double
    let longitude: Double
}


struct PhoneContact: Identifiable, Equatable {
    let id = UUID()
    let firstName: String
    let lastName: String
    let phone: String
    let email: String
    
    static func == (lhs: PhoneContact, rhs: PhoneContact) -> Bool {
            return lhs.id == rhs.id
        }
}

class ContactsViewModel: ObservableObject {
    @Published var contacts = [PhoneContact]()
    @Published var filteredContacts = [PhoneContact]()
    @Published var isSearchViewActive = false
    @Published var searchText = "" {
        didSet {
            filterContacts()
        }
    }

    init() {
        fetchContacts()
    }

    func fetchContacts() {
        DispatchQueue.global(qos: .userInitiated).async {
            let store = CNContactStore()
            store.requestAccess(for: .contacts) { granted, error in
                guard granted else {
                    return
                }
                let keysToFetch = [
                    CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
                    CNContactPhoneNumbersKey as CNKeyDescriptor,
                    CNContactEmailAddressesKey as CNKeyDescriptor
                ]
                let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch)
                do {
                    var contacts = [PhoneContact]()
                    try store.enumerateContacts(with: fetchRequest) { contact, _ in
                        let fullName = CNContactFormatter.string(from: contact, style: .fullName) ?? ""
                        var firstName = ""
                        var lastName = ""

                        if !fullName.isEmpty {
                            let nameParts = fullName.split(separator: " ")
                            if nameParts.count > 1 {
                                firstName = String(nameParts[0])
                                lastName = String(nameParts[1])
                            } else {
                                firstName = String(nameParts[0])
                            }
                        }

                        let phoneNumbers = contact.phoneNumbers.map { $0.value.stringValue }
                        let emailAddresses = contact.emailAddresses.map { $0.value as String }
                        let contactObject = PhoneContact(firstName: firstName, lastName: lastName, phone: phoneNumbers.first ?? "", email: emailAddresses.first ?? "")
                        contacts.append(contactObject)
                    }
                    DispatchQueue.main.async {
                        self.contacts = contacts
                        self.filteredContacts = contacts
                    }
                } catch {
                    print(error)
                }
            }
        }
    }

    func filterContacts() {
        if searchText.isEmpty {
            filteredContacts = contacts
        } else {
            filteredContacts = contacts.filter { contact in
                let searchText = self.searchText.lowercased()
                let firstName = contact.firstName.lowercased()
                let lastName = contact.lastName.lowercased()
                let phone = contact.phone.lowercased()
                let email = contact.email.lowercased()
                return firstName.contains(searchText) || lastName.contains(searchText) || phone.contains(searchText) || email.contains(searchText)
            }
        }
    }
}


