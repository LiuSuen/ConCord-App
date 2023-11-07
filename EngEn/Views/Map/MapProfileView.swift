//
//  MapProfileView.swift
//  EngEn
//
//  Created by dc on 3/26/23.
//

import SwiftUI


struct MapProfileView: View {
    let friends: [Friend]
    @Binding var isPresented: Bool

    var body: some View {
        NavigationView {
            List(friends) { friend in
                FriendRow(friend: friend)
            }
            .navigationBarTitle("Friends", displayMode: .inline)
            .navigationBarItems(trailing:
                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            )
        }
    }
}

import SwiftUI

struct FriendRow: View {
    @FetchRequest(sortDescriptors: [], animation: .default)
    private var contacts: FetchedResults<Contacts>
    let friend: Friend
    @State private var isProfileViewPresented: Bool = false
    
    func friend_to_contact(friend:Friend)->Contacts{
        for i in contacts{
            let a = "\(i.firstName ?? "Unknown") \(i.lastName ?? "Unknown")"
            if a == friend.name{
                return i
            }
        }
        return contacts[0]
    }
    

    var body: some View {
        HStack {
            Image(uiImage: imageFromString(friend_to_contact(friend: friend).picture ?? ""))
                .resizable()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .overlay {
                    Circle().stroke(.white, lineWidth: 2)
                }
            VStack(alignment: .leading) {
                Text(friend.name)
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(Color(red: 0.0, green: 0.2, blue: 0.0))
                Text("City: \(friend.city)")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(Color(red: 0.0, green: 0.2, blue: 0.0))
                Text("State: \(friend.state)")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(Color(red: 0.0, green: 0.2, blue: 0.0))
                Text("Country: \(friend.country)")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(Color(red: 0.0, green: 0.2, blue: 0.0))
            }
            Spacer()
            Button(action: {
                isProfileViewPresented.toggle()
            }) {
                Text("View Profile")
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(Color(red: 0.0, green: 0.2, blue: 0.0))
            }
            .sheet(isPresented: $isProfileViewPresented) {
                ReadOnlyView(newContact: friend_to_contact(friend:friend))
            }
        }
    }
}




