//
//  SearchView.swift
//  EngEn
//
//  Created by Suen Lau on 2023/3/25.


import SwiftUI

//  MARK: display all the contacts in this view, and allow user to search
struct SearchView: View {
    @FetchRequest(sortDescriptors: [], animation: .default)
    private var contacts: FetchedResults<Contacts>
        
    @State private var searchWord = ""
    @ObservedObject var planData = PlanData.shared
    var filteredContacts: Array<Contacts> {
            if searchWord.isEmpty {
                return Array(contacts)
            } else {
                return contacts.filter { contact in
                    let search = searchWord.lowercased()
                    return (contact.firstName ?? "").lowercased().contains(search) ||
                           (contact.lastName ?? "").lowercased().contains(search) ||
                           (contact.city ?? "").lowercased().contains(search) ||
                           (contact.state ?? "").lowercased().contains(search) ||
                           (contact.country ?? "").lowercased().contains(search) ||
                           (contact.phone ?? "").lowercased().contains(search) ||
                           (contact.email ?? "").lowercased().contains(search) ||
                           (contact.notes ?? "").lowercased().contains(search)
                }
            }
        }

    var body: some View {
        VStack{
            NavigationView {
                List{
                    ForEach(filteredContacts){ contact in
                        NavigationLink {
                            ReadOnlyView(newContact:contact)
                        } label:{
                            RowView(person: contact)
                        }
                        
                    }
                    .background(RoundedRectangle(cornerRadius: 12).fill(.white))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                }
                .listStyle(.insetGrouped)
                .searchable(text:$searchWord)
            }
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
        RowView(person:ContactsData().contacts[0])
    }
}

// MARK: the view of a row of a contact
struct RowView: View{
    var person: Contacts

    var body: some View {
        ZStack {
            HStack {
                VStack(alignment: .leading){
                    Text("\(person.firstName ?? "FName") \(person.lastName ?? "LName")")
                        .font(.system(size: 24, design: .rounded))
                        .bold()
                        .foregroundColor(Color(red: 0.0, green: 0.2, blue: 0.0))
                    HStack{
                        Image(uiImage: imageFromString(person.flag ?? ""))
                            .resizable()
                            .frame(width: 20, height: 20)
                            .clipShape(Circle())
                        Text("\(person.city ?? "City"), \(person.state ?? "State"), \(person.country ?? "Country")")
                            .font(.system(size: 15, design: .rounded))
                            .italic()
                            .foregroundColor(Color(red: 0.0, green: 0.2, blue: 0.0))
                        
                        
                    }
                }
                .padding(.leading)
                Spacer()
            }
        }
        .padding()
        
    }
}
