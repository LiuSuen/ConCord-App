//
//  ContactView.swift
//  EngEn
//
//  Created by Loaner on 3/22/23.
//

import SwiftUI
import CoreLocation
import FlagKit

struct ContactView: View {
    @Environment(\.managedObjectContext) var viewContext
    @ObservedObject var contact: Contacts
    var location: City?
    @State private var distance: Double = 0.0
    @State private var userLatitude: Double = 0.0
    @State private var userLongitude: Double = 0.0
    @State private var showingDeleteConfirmation = false
    @State var editIsActive = false
    let locationManager = CLLocationManager()
    
    
    var body: some View {
        NavigationLink(destination: EditView(updateContact: contact)){
            HStack(alignment: .center, spacing: 10) {
                ZStack {
                    Image(uiImage: imageFromString(contact.picture ?? ""))
                        .resizable()
                        .frame(width: 70, height: 70)
                        .clipShape(Circle())
                        .overlay {
                            Circle().stroke(.white, lineWidth: 2)
                        }
                        .shadow(radius: 7)
                    
                    if contact.reminder {
                        Image(systemName: "calendar.badge.clock.rtl")
                            .foregroundColor(.blue)
                            .offset(x: 30, y: 27)
                    }
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("\(contact.firstName ?? "Unknown") \(contact.lastName ?? "Unknown")")
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(Color(red: 0.0, green: 0.2, blue: 0.0))
                    HStack {
                        Image(uiImage: imageFromString(contact.flag ?? ""))
                            .resizable()
                            .frame(width: 20, height: 20)
                            .clipShape(Circle())
                        Toggle(isOn: Binding(
                            get: { contact.tovisit },
                            set: { newValue in
                                contact.tovisit = newValue
                                contact.reminder = false
                                // Save changes to Core Data
                                if viewContext.hasChanges {
                                    withAnimation {
                                        do {
                                            try viewContext.save()
                                        } catch {
                                            print("Error saving changes to Core Data: \(error)")
                                        }
                                    }
                                }
                            }))
                        {
                            Text("\(contact.city ?? "Unknown"), \(contact.country ?? "Unknown")")
                                .font(.system(.callout, design: .rounded))
                                .fontWeight(.semibold)
                                .foregroundColor(contact.tovisit ? Color(red: 0.0, green: 0.2, blue: 0.0) : Color(.gray))
                        }
                    }.padding(.horizontal)
                    
                    Text("\(contact.notes ?? "Notes not avilable")")
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(Color(red: 0.0, green: 0.2, blue: 0.0))
                    
                    
                    Text("Distance from me: \(String(format: "%.1f", contact.distance)) km")
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(Color(red: 0.0, green: 0.2, blue: 0.0))
                    
                }
            }
            .onAppear {
                let contacts = ContactsData().contacts
                locationManager.requestWhenInUseAuthorization() // Request location authorization
                locationManager.startUpdatingLocation() // Start updating location
                
                // Get user's current location
                if let userLocation = locationManager.location {
                    let userCLLocation = CLLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
                    
                    // Update the distance for each contact
                    for contact in contacts {
                        if contact.lat != 0.000000 && contact.lng != 0.000000 {
                            let contactCLLocation = CLLocation(latitude: contact.lat, longitude: contact.lng)
                            let distanceInMeters = userCLLocation.distance(from: contactCLLocation)
                            let distanceInKilometers = distanceInMeters / 1000
                            contact.distance = distanceInKilometers
                        } else {
                            let location = searchCity(city: contact.city!, country: contact.country!, state: contact.state!)
                            if let lat = location.first?.lat, let lng = location.first?.lng {
                                let contactCLLocation = CLLocation(latitude: lat, longitude: lng)
                                let distanceInMeters = userCLLocation.distance(from: contactCLLocation)
                                let distanceInKilometers = distanceInMeters / 1000
                                contact.distance = distanceInKilometers
                            } else {
                                // Handle the case where the location cannot be determined
                                print("Cannot determine location for contact")
                            }
                        }
                    }
                } else {
                    // Handle the case where the user's location cannot be determined
                    print("Cannot determine user's location")
                }
                
            }
            .swipeActions(edge: .leading) {
                Button {
                    editIsActive.toggle()
                } label: {
                    Label("Profile", systemImage: "person")
                }
                .tint(.blue)
            }
            
            .sheet(isPresented: $editIsActive,content: {
                ReadOnlyView(newContact: contact)
            })
            .swipeActions(edge: .leading) {
                Button {
                    // Show a confirmation alert before deleting the Core Data object
                    showingDeleteConfirmation = true
                } label: {
                    Label("Delete", systemImage: "trash")
                }
                .tint(.red)
            }
            .alert(isPresented: $showingDeleteConfirmation) {
                Alert(title: Text("Delete Contact"), message: Text("Are you sure you want to delete this contact?"), primaryButton: .cancel(), secondaryButton: .destructive(Text("Delete")) {
                    deleteContact(contact: contact, viewContext: viewContext)
                })
            }
            
        }
        .background(contact.distance < 70 ? Color(red: 0.0, green: 0.5, blue: 0.0).opacity(0.2) : Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct ContactView_Previews: PreviewProvider {
    static var previews: some View {
        ContactView(contact: ContactsData().contacts[0])
    }
}
