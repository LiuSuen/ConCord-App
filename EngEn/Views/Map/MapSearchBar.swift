//
//  MapSearchBar.swift
//  EngEn
//
//  Created by dc on 3/25/23.
//

import SwiftUI

struct MapSearchBar: View {
    @Binding var text: String
    var onSearch: () -> Void
    var allCities: Set<String>
    @Binding var filteredCities: [String]
    @Binding var show: Bool

    var body: some View {
        VStack {
            HStack {
                TextField("Search by city, state, country", text: Binding<String>(
                    get: { self.text },
                    set: {
                        self.text = $0
                        self.filterCities()
                        show = true
                    }))
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .font(.system(size: 16))
                    .overlay(
                        HStack {
                            Spacer()
                            if !text.isEmpty {
                                Button(action: {
                                    self.text = ""
                                    onSearch()
                                    filterCities()
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.gray)
                                        .padding(.trailing, 8)
                                }
                            }
                        }
                    )

                Button(action: {
                    onSearch()
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    show = false
                    
                }) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 20))
                        .padding(12)
                }
            }
            .padding(.horizontal)
        }
    }

    func filterCities() {
        if text.isEmpty {
            filteredCities = []
        } else {
            filteredCities = allCities.filter { city in
                city.lowercased().contains(text.lowercased())
            }
        }
    }
}

struct CityListView: View {
    @Binding var cities: [String]
    @Binding var searchText: String
    @Binding var show: Bool

    var body: some View {
        List(cities, id: \.self) { city in
            Button(action: {
                searchText = city
                show = false
            }) {
                Text(city)
            }
        }
        .frame(maxHeight: cities.isEmpty ? 0 : .infinity)
    }
}




