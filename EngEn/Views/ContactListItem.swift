//
//  ContactListItem.swift
//  EngEn
//
//  Created by Loaner on 3/27/23.
//

import SwiftUI

struct ContactListItem: View {
    var contact: Contacts
       
       var body: some View {
           RoundedRectangle(cornerRadius: 10)
               .foregroundColor(.white)
               .shadow(radius: 2)
               .overlay(
                   ContactView(contact: contact)
                       .padding()
                       .fixedSize(horizontal: false, vertical: true)
               )
               .padding(.horizontal)
               .padding(.vertical, 5)
       }
   }

struct ContactListItem_Previews: PreviewProvider {
    static var previews: some View {
        ContactListItem(contact: ContactsData().contacts[0])
    }
}
