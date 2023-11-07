//
//  SelectView.swift
//  EngEn
//
//  Created by Suen Lau on 2023/4/10.
//

import SwiftUI

//the row view of a contact in the Plan View
struct SelectRowView: View {
    var person: Contacts
    @Environment(\.managedObjectContext) var viewContext
    var body: some View {
        ZStack{
            HStack {
                VStack(alignment: .leading){
                    Text("\(person.firstName ?? "FName") \(person.lastName ?? "LName")")
                        .font(.system(size: 20, design: .rounded))
                        .bold()
                        .foregroundColor(Color(red: 0.0, green: 0.2, blue: 0.0))
                    Text("\(person.notes ?? "Notes")")
                        .font(.system(size: 15, design: .rounded))
                        .foregroundColor(Color(red: 0.0, green: 0.2, blue: 0.0))
                }
                //Toggle of toVisit
                Toggle("", isOn: Binding(
                    get: { person.tovisit },
                    set: { newValue in
                        person.tovisit = newValue
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
                    })).toggleStyle(SwitchToggleStyle(tint: .blue))
            }
            .padding(.horizontal)
            Spacer()
        }
        //.padding(20)
    }
}

struct SelectRowView_Previews: PreviewProvider {
    static var previews: some View {
        SelectRowView(person:ContactsData().contacts[0])
    }
}
