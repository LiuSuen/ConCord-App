//
//  ContactsSearchView.swift
//  EngEn
//
//  Created by Loaner on 3/31/23.
//

import SwiftUI

struct ContactsSearchView: View {
    @Binding var selectedContact: PhoneContact?
    @ObservedObject var contactsViewModel: ContactsViewModel
    let emptycontact = PhoneContact(firstName: "", lastName: "", phone: "", email: "")
    
    var body: some View {
        VStack{
            HStack {
                Spacer()
                Button(action: {
                    selectedContact = emptycontact
                    
                }) {
                    Image(systemName: "xmark")
                        .padding(1)
                }
            }
            if contactsViewModel.filteredContacts.isEmpty {
                // If there are no search results, hide the search view
                EmptyView()
            } else {
                List(contactsViewModel.filteredContacts) { contact in
                    Button(action: {
                        selectedContact = contact
                    }) {
                        Text("\(contact.firstName) \(contact.lastName)")
                    }
                }
                .frame(height: 90)
                .listStyle(.plain)
                .background(Color.clear)
                .cornerRadius(8)
                .shadow(radius: 4)
                .padding()
            }
        }
    }
}

