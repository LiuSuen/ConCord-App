//
//  PlanView.swift
//  EngEn
//
//  Created by Suen Lau on 2023/4/10.
//

import SwiftUI

struct PlanView: View {
    @State var newPlan: PlanItem = PlanItem()
    @ObservedObject var planData = PlanData.shared
    @State private var dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            return formatter
        }()
    @ObservedObject var mapAPI = MapAPI()
    @State var query = ""
    @State var matches: [String] = []
    @State var selectedLocation: Location?
    
    @FetchRequest(sortDescriptors: [], animation: .default)
    private var contacts: FetchedResults<Contacts>
    @Environment(\.presentationMode) var presentationMode
    
    var filteredContacts: [Contacts] {//return contacts in this city
        if newPlan.city == "" {
            return Array(contacts)
        } else {
            return contacts.filter { contact in
                return (contact.city ?? "").lowercased().trimmingCharacters(in: .whitespaces).contains(newPlan.city.lowercased().trimmingCharacters(in: .whitespaces)) &&
                (contact.state ?? "").lowercased().trimmingCharacters(in: .whitespaces).contains(newPlan.state.lowercased().trimmingCharacters(in: .whitespaces)) &&
                (contact.country ?? "").lowercased().trimmingCharacters(in: .whitespaces).contains(newPlan.country.lowercased().trimmingCharacters(in: .whitespaces)) }
        }
    }
    var body: some View {
        VStack{
            VStack{
                Form {
                    HStack{
                        Text("Plan a trip").font(.largeTitle).bold()
                    }
                    HStack{
                        Text("Begin Date").fontWeight(.semibold)
                        Spacer()
                        DatePicker("Enter Begin Date", selection: $newPlan.beginDate, displayedComponents: .date)
                                            .labelsHidden()
                                            .multilineTextAlignment(.trailing)
                    }
                    HStack{
                        Text("End Date").fontWeight(.semibold)
                        Spacer()
                        DatePicker("Enter End Date", selection: $newPlan.endDate, displayedComponents: .date)
                                            .labelsHidden()
                                            .multilineTextAlignment(.trailing)
                    }
                    VStack {
                        TextField("Search city to auto-fill", text: $query, onEditingChanged: { _ in
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
                        
                        List(matches, id: \.self) { match in
                            let matchComponents = match.split(separator: ",")
                            if matchComponents.count >= 3 {
                                let cityStateSlice = matchComponents[0..<matchComponents.count-2]
                                let cityState = cityStateSlice.joined(separator: ", ")
                                Text(cityState)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .contentShape(Rectangle())
                                    .onTapGesture {//auto match the city/state/country to their textfield
                                        newPlan.city = String(matchComponents[0])
                                        newPlan.state = String(matchComponents[1])
                                        newPlan.country = String(matchComponents[2])
                                        newPlan.location = newPlan.city + newPlan.state + newPlan.country
                                        matches.removeAll()
                                        query = ""
                                    }
                            }
                        }
                        .opacity(matches.isEmpty ? 0 : 1)
                    }
                    HStack {
                        Text("City").fontWeight(.semibold)
                        Spacer()
                        TextField("City", text: Binding(
                            get: { newPlan.city },
                            set: { newPlan.city = $0 }
                        )).multilineTextAlignment(.trailing)
                            .disabled(true)
                    }
                    HStack{
                        Text("State").fontWeight(.semibold)
                        Spacer()
                        TextField("State", text: Binding(
                            get: { newPlan.state },
                            set: { newPlan.state = $0 }
                        )).multilineTextAlignment(.trailing)
                            .disabled(true)
                    }
                    HStack{
                        Text("Country").fontWeight(.semibold)
                        Spacer()
                        TextField("Country", text: Binding(
                            get: { newPlan.country },
                            set: { newPlan.country = $0 }
                        )).multilineTextAlignment(.trailing)
                            .disabled(true)
                    }
                }.frame(height:400)//Form
            }
            Spacer()
            if filteredContacts.count == 0 {
                Text("Sorry, there is no contact in this city. \nPlease try another one.")
            }
            else{
                //to show the contact list result
                List{
                    ForEach(filteredContacts){ contact in
                        NavigationLink {
                            ReadOnlyView(newContact:contact)
                        } label:{
                            SelectRowView(person: contact)
                        }
                    }
                }.listStyle(.plain)
            }
            HStack{
                Button(action: {
                    self.newPlan = PlanItem()
                    presentationMode.wrappedValue.dismiss()
                }, label:{Text("Cancel").foregroundColor(.blue).fontWeight(.bold)} )
                Spacer()
                Button(action:{
                    for item in filteredContacts {
                        if item.tovisit == true {
                            let name = "\(item.firstName ?? "Unknown") \(item.lastName ?? "Unknown")"
                            newPlan.peopleList.append(name)
                        }
                    }
                    planData.addPlan(newItem: newPlan)
                },label:{
                    Text("Make a plan")
                    .foregroundColor(.white).fontWeight(.bold)}).frame(width:150, height: 40).background(Color.yellow)
                    .cornerRadius(20)
            }.frame(width:350)
            
        }
    }
}

struct PlanView_Previews: PreviewProvider {
    static var previews: some View {
        PlanView(newPlan: PlanItem())
    }
}
