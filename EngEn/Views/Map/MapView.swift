//
//  MapView.swift
//  EngEn
//
//  Created by dc on 3/23/23.
//

import SwiftUI
import MapKit
import CoreLocation

struct Friend: Identifiable {
    let id = UUID()
    let name: String
    let city: String
    let state: String
    let country: String
    let coordinate: CLLocationCoordinate2D
    var highlight: Bool
}

extension CLLocationCoordinate2D: Equatable {
    public static func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

struct MapView: View {
    @FetchRequest(sortDescriptors: [], animation: .default)
    private var contacts: FetchedResults<Contacts>
    
    private let locationManager = CLLocationManager()
        
        init() {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }


    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060),
        span: MKCoordinateSpan(latitudeDelta: 80, longitudeDelta: 80)
    )
    
    private var friends: [Friend] {
        contacts.map { contact in
            let cityCoordinates = searchCity(city: contact.city!, country: contact.country!, state: contact.state!)
            let friendName = "\(contact.firstName ?? "Unknown") \(contact.lastName ?? "Unknown")"
            let city = "\(contact.city ?? "Unknown")".trimmingCharacters(in: .whitespaces)
            let state = "\(contact.state ?? "Unknown")".trimmingCharacters(in: .whitespaces)
            let country = "\(contact.country ?? "Unknown")".trimmingCharacters(in: .whitespaces)
            if cityCoordinates == []{
                let coordinate = CLLocationCoordinate2D(latitude: contact.lat, longitude: contact.lng)
                return Friend(name: friendName, city: city, state: state, country: country, coordinate: coordinate, highlight: false)
            }
            let coordinate = CLLocationCoordinate2D(latitude: cityCoordinates[0].lat, longitude: cityCoordinates[0].lng)
            return Friend(name: friendName, city: city, state: state, country: country, coordinate: coordinate, highlight: false)
        }
        
    }
    private var cities: Set<String>{
        Set(friends.map{friend in
            return "\(friend.city), \(friend.state), \(friend.country)"
        })
    }
    
    @State private var searchText = ""

    private var filteredFriends: [Friend] {
        if search.isEmpty {
            return friends
        } else {
            return friends.map { friend in
                var modifiedFriend = friend
                modifiedFriend.highlight = "\(modifiedFriend.city.lowercased()), \(modifiedFriend.state.lowercased()), \(modifiedFriend.country.lowercased())" == search.lowercased()
                return modifiedFriend
            }
        }
    }
    func friendlist(friend:Friend)->[Friend]{
        var list:[Friend] = []
        for i in friends{
            if i.city == friend.city && i.state == friend.state && i.country == friend.country{
                list.append(i)
            }
        }
        return list
        
    }
    
    
    @State private var selectedFriend: Friend? = nil
    @State private var showProfileView: Bool = false
    @State private var search: String = ""
    @State var isPresentingAddView = false
    @State var filteredcity : [String] = []
    @State var showcitylist = true
    

    func filter() {
        search = searchText
        for friend in filteredFriends {
            if "\(friend.city.lowercased()), \(friend.state.lowercased()), \(friend.country.lowercased())" == (searchText.lowercased()) {
                withAnimation {
                    region = MKCoordinateRegion(center: friend.coordinate, span: region.span)
                }
                break
            }
        }
    }
        
    

    var body: some View {
        ZStack(alignment: .bottomTrailing){
            VStack{
                MapSearchBar(text: $searchText, onSearch: filter, allCities: cities, filteredCities: $filteredcity, show: $showcitylist)
                    .padding(.top, 5)
                    .frame(height: 40)
                Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: filteredFriends) { friend in
                    MapAnnotation(coordinate: friend.coordinate) {
                        Button(action: {
                            withAnimation(.easeInOut) {
                                selectedFriend = friend
                                showProfileView = true
                            }
                        }) {
                            MapAnnotationView(friend: friend)
                        }
                                
                    }
                }

            }
            if showcitylist{
                CityListView(cities: $filteredcity, searchText: $searchText, show: $showcitylist)
                    .padding(.top, 45)
            }
            
            Spacer()
            Button(action: {
                if let userLocation = locationManager.location?.coordinate {
                    withAnimation{
                        region = MKCoordinateRegion(center: userLocation, span: region.span)
                    }
                }
            }) {
                Image(systemName: "location.fill")
            }
            .frame(width: 44, height: 44)
            .background(Color.white.opacity(0.8))
            .cornerRadius(22)
            .padding(.trailing, 20)
            .padding(.bottom, 50)


            Button(action: {
                isPresentingAddView = true
            }) {
                Image(systemName: "person.fill.badge.plus")
            }
            .sheet(isPresented: $isPresentingAddView, content: {
                AddView()
            })
            .frame(width: 44, height: 44)
            .background(Color.white.opacity(0.8))
            .cornerRadius(22)
            .padding(.trailing, 20)
            .padding(.bottom, 120)
            
            if showProfileView {
                MapProfileView(friends: friendlist(friend: selectedFriend!), isPresented: $showProfileView)
                    .background(Color.white)
                    .cornerRadius(10)
                    .padding(.top,400)
                    .transition(.move(edge: .bottom))
                    
            }
        }

    }
}


