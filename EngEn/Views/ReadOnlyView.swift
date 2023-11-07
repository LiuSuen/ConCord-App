//
//  ReadOnlyView.swift
//  EngEn
//
//  Created by Loaner on 3/31/23.
//

import SwiftUI
import Contacts

struct ReadOnlyView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @FetchRequest(sortDescriptors: [], animation: .default)
    private var contacts: FetchedResults<Contacts>
    @State private var showContactView = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State var newContact: Contacts
    
    var body: some View {
        VStack{
            Image(uiImage: imageFromString(newContact.picture ?? ""))
                .resizable()
                .frame(width: 75, height: 75)
                .clipShape(Circle())
                .overlay {
                    Rectangle().stroke(.white)
                }
            Button("Add To My Phone Contacts") {
                let store = CNContactStore()
                let predicate = CNContact.predicateForContacts(matchingName: "\(newContact.firstName ?? "") \(newContact.lastName ?? "")")
                let existingContacts = try? store.unifiedContacts(matching: predicate, keysToFetch: [])
                if existingContacts?.isEmpty ?? true {
                    showContactView.toggle()
                } else {
                    showAlert = true
                    alertMessage = "Contact already exists in your phone"
                }
            }
            .sheet(isPresented: $showContactView) {
                NewContactView(firstName: newContact.firstName ?? "", lastName: newContact.lastName ?? "", phoneNumber: newContact.phone ?? "", emailAddress: newContact.email ?? "")
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }

            Form {
                HStack{
                    Text("First Name").fontWeight(.semibold)
                    Spacer()
                    TextField("Enter First Name", text: Binding(
                        get: { newContact.firstName ?? "" },
                        set: { newContact.firstName = $0 }
                    ))
                    .textInputAutocapitalization(.never)
                    .multilineTextAlignment(.trailing)
                    .disabled(true)
                }
                HStack{
                    Text("Last Name").fontWeight(.semibold)
                    Spacer()
                    TextField("Enter Last Name", text: Binding(
                        get: { newContact.lastName ?? "" },
                        set: { newContact.lastName = $0 }
                    )).multilineTextAlignment(.trailing)
                        .disabled(true)
                }
                HStack{
                    Text("City").fontWeight(.semibold)
                    Spacer()
                    TextField("Enter City", text: Binding(
                        get: { newContact.city ?? "" },
                        set: { newContact.city = $0 }
                    )).multilineTextAlignment(.trailing)
                        .disabled(true)
                }
                HStack{
                    Text("State").fontWeight(.semibold)
                    Spacer()
                    TextField("Choose State", text: Binding(
                        get: { newContact.state ?? "" },
                        set: { newContact.state = $0 }
                    )).multilineTextAlignment(.trailing)
                        .disabled(true)
                }
                HStack{
                    Text("Country").fontWeight(.semibold)
                    Spacer()
                    TextField("Choose Country", text: Binding(
                        get: { newContact.country ?? "" },
                        set: { newContact.country = $0 }
                    )).multilineTextAlignment(.trailing)
                        .disabled(true)
                }
                HStack{Button(action: {//to tap to send an email
                    guard let email = newContact.email, let emailUrl = URL(string: "mailto:\(email)") else {
                        return
                    }
                    UIApplication.shared.open(emailUrl)
                }) {
                    Image(systemName: "envelope.circle")
                }
                    Text("Email").fontWeight(.semibold)
                    Spacer()
                    TextField("Enter Email", text: Binding(
                        get: { newContact.email ?? "" },
                        set: { newContact.email = $0 }
                    )).multilineTextAlignment(.trailing)
                        .disabled(true)
                }
                HStack{
                    Button(action: {//to tap to make a phone call
                        guard let phone = newContact.phone, let phoneUrl = URL(string: "tel://\(phone)") else {
                            return
                        }
                        UIApplication.shared.open(phoneUrl)
                    }) {
                        Image(systemName: "phone.circle")
                    }
                    Text("Phone").fontWeight(.semibold)
                    Spacer()
                    TextField("Enter Phone Number", text:Binding(
                        get: { newContact.phone ?? "" },
                        set: { newContact.phone = $0 }
                    )).multilineTextAlignment(.trailing)
                        .disabled(true)
                }
                VStack(alignment: .leading){
                    Text("Notes").fontWeight(.semibold)
                    TextField("Enter Notes", text: Binding(
                        get: { newContact.notes ?? "" },
                        set: { newContact.notes = $0 }
                    )).foregroundColor(.gray)
                        .disabled(true)
                }
            }//Form
        }//VStack in Body
    }//Body
}

struct ReadOnlyView_Previews: PreviewProvider {
    static var previews: some View {
        ReadOnlyView(newContact: ContactsData().contacts[0])
    }
}
