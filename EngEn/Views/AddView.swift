//
//  AddView.swift
//  EngEn
//
//  Created by Suen Lau on 2023/3/25.
//

import SwiftUI
import MapKit
import Contacts
import Combine

struct AddView: View {
    @ObservedObject var mapAPI = MapAPI()
    @State var query = ""
    @State var matches: [String] = []
    @State var selectedLocation: Location?
    @ObservedObject var contactsViewModel = ContactsViewModel()
    @State var selectedContact: PhoneContact?
    @State private var isShowingImagePicker = false
    
    @Environment(\.presentationMode) var presentationMode
    
    @FetchRequest(sortDescriptors: [], animation: .default)
    private var contacts: FetchedResults<Contacts>
    @State var newContact = NewContactData(lat: 0.0, lng: 0.0)
    
    
    var body: some View {
        VStack{
            Image(uiImage:  (newContact.picture ?? avatar) ?? UIImage())
                .resizable()
                .frame(width: 70, height: 70)
                .clipShape(Circle())
            Button(action: {
                           isShowingImagePicker = true
                       }) {
                           Text("Choose Photo")
                       }
                       .sheet(isPresented: $isShowingImagePicker, onDismiss: loadImage) {
                           ImagePicker(image: $newContact.picture)
                       }
            Section(header: Text("New Contact Information").font(.headline)) {
                Form {
                    HStack{
                        Text("First Name").fontWeight(.semibold)
                        Spacer()
                        TextField("Enter First Name", text: Binding(
                            get: { newContact.firstName ?? "" },
                            set: { newContact.firstName = $0 }
                        ))
                        .onChange(of: newContact.firstName ?? "", perform: { value in
                            contactsViewModel.searchText = value
                        })
                        .textInputAutocapitalization(.never)
                        .multilineTextAlignment(.trailing)
                    }
                    HStack{
                        Text("Last Name").fontWeight(.semibold)
                        Spacer()
                        TextField("Enter Last Name", text: Binding(
                            get: { newContact.lastName ?? "" },
                            set: { newContact.lastName = $0 }
                        )).multilineTextAlignment(.trailing)
                    }
                    VStack {
                        //use mapAPI to get the location's name infomation
                        TextField("Search city", text: $query, onEditingChanged: { _ in
                            if !query.isEmpty {
                                mapAPI.getLocations(query: query) { locations in
                                    DispatchQueue.main.async {
                                        matches = locations.prefix(10).map { $0 }
                                    }
                                }
                            } else {
                                matches.removeAll()
                            }
                        })
                        .textFieldStyle(.roundedBorder)
                        withAnimation(.easeInOut(duration: 0.2)) {
                            List(matches, id: \.self) { match in
                                let matchComponents = match.split(separator: ",")
                                if matchComponents.count >= 3 {
                                    let cityStateSlice = matchComponents[0..<matchComponents.count-2]
                                    let cityState = cityStateSlice.joined(separator: ", ")
                                    Text(cityState)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .contentShape(Rectangle())
                                        .onTapGesture {//auto match the city/state/country to their textfield
                                            newContact.city = String(matchComponents[0])
                                            newContact.state = String(matchComponents[1])
                                            newContact.country = String(matchComponents[2])
                                            newContact.lat = Double(matchComponents[3].trimmingCharacters(in: .whitespaces)) ?? 0.0
                                            newContact.lng = Double(matchComponents[4].trimmingCharacters(in: .whitespaces)) ?? 0.0
                                            matches.removeAll()
                                            query = ""
                                        }
                                }
                            }
                            .opacity(matches.isEmpty ? 0 : 1)
                        }
                    }
                    HStack {
                        Text("City").fontWeight(.semibold)
                        Spacer()
                        TextField("City", text: Binding(
                            get: { newContact.city ?? "" },
                            set: { newContact.city = $0 }
                        )).multilineTextAlignment(.trailing)
                            .disabled(true)
                    }
                    HStack{
                        Text("State").fontWeight(.semibold)
                        Spacer()
                        TextField("State", text: Binding(
                            get: { newContact.state ?? "" },
                            set: { newContact.state = $0 }
                        )).multilineTextAlignment(.trailing)
                            .disabled(true)
                    }
                    HStack{
                        Text("Country").fontWeight(.semibold)
                        Spacer()
                        TextField("Country", text: Binding(
                            get: { newContact.country ?? "" },
                            set: { newContact.country = $0 }
                        )).multilineTextAlignment(.trailing)
                            .disabled(true)
                    }
                    HStack{
                        Text("Email").fontWeight(.semibold)
                        Spacer()
                        TextField("Enter Email", text: Binding(
                            get: { newContact.email ?? "" },
                            set: { newContact.email = $0 }
                        )).multilineTextAlignment(.trailing)
                    }
                    HStack{
                        Text("Phone").fontWeight(.semibold)
                        Spacer()
                        TextField("Enter Phone Number", text:Binding(
                            get: { newContact.phone ?? "" },
                            set: { newContact.phone = $0 }
                        )).multilineTextAlignment(.trailing)
                    }
                    VStack(alignment: .leading){
                        Text("Notes").fontWeight(.semibold)
                        TextField("Enter Notes", text: Binding(
                            get: { newContact.notes ?? "" },
                            set: { newContact.notes = $0 }
                        )).foregroundColor(.gray)
                    }
                }
            }//Form
            if newContact.firstName?.isEmpty == false && selectedContact == nil {
                ContactsSearchView(selectedContact: $selectedContact, contactsViewModel: contactsViewModel)
            }
            
            HStack{
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label:{Text("Cancel").foregroundColor(.blue).fontWeight(.bold)} )
                Spacer()
                Button(action:{//to add the contact
                    addContact(person: newContact){ result in
                        switch result {
                        case .success:
                            print("Contact added successfully.")
                        case .failure(let error):
                            print("Error adding contact: \(error.localizedDescription)")
                        }
                    }
                },label:{Text("Confirm").foregroundColor(.white).fontWeight(.bold)}).frame(width:150, height: 40).background(Color.green)
                    .cornerRadius(20)
            }.frame(width:350)//HStack of Buttons
            
        }//VStack in Body
        .onChange(of: selectedContact, perform: { value in
            // Hide the ContactsSearchView when a contact is selected
            if value != nil {
                newContact.firstName = value!.firstName
                newContact.lastName = value!.lastName
                newContact.phone = value!.phone
                newContact.email = value!.email
                contactsViewModel.searchText = ""
            }
        })
        
    }//Body
    func loadImage() {
        guard newContact.picture != nil else { return }
        //image = Image(uiImage: inputImage)
    }
}

struct AddView_Previews: PreviewProvider {
    static var previews: some View {
        AddView()
    }
}
