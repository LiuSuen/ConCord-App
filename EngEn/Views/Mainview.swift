//
//  ContentView.swift
//  EngEn
//
//  Created by Loaner on 3/21/23.
//

import SwiftUI
import CoreData

struct MainView: View {
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Contacts.distance, ascending: true)], animation: .default)
    private var contacts: FetchedResults<Contacts>
    
    @FetchRequest(entity: Profile.entity(), sortDescriptors: [], animation: .default)
    private var profiles: FetchedResults<Profile>
    @Environment(\.managedObjectContext) var viewContext
     
    
    @State private var isPresented = false
    @State private var isFiltered = false
    @State private var isFilteredDist = false
    @State private var isShowingImage = false
    @State private var selectedImage: UIImage?
    
    
    var groupedContacts: [String: [Contacts]] {
        Dictionary(grouping: contacts) { $0.country ?? "" }
    }
    
    var filteredContacts: [Contacts] {
        if isFiltered {
            return contacts.filter { $0.tovisit == true }
        } else {
            return Array(contacts)
        }
    }
    
    var filteredDistContacts: [Contacts] {
        if isFilteredDist {
            return contacts.filter { $0.distance < 70.0 }
        } else {
            return Array(contacts)
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Image("bg-photo")
                    .resizable()
                    .aspectRatio(UIImage(named: "bg-photo")!.size, contentMode: .fit)
                    .offset(x:0, y: -330)//UIImage(named: "Back")!
                    .ignoresSafeArea()
                CircleImage(image: Image(uiImage: imageFromString(profiles.first?.picture ?? "")))
                        .offset(x: 0, y: -340)
                        .padding(.bottom, -70 )
                        Button(action: {
                            isShowingImage = true
                        }) {
                            Label(
                                title: { Text("Add Photo") },
                                icon: { Image(systemName: "plus") }
                            )
                            .labelStyle(.iconOnly)
                            .frame(width: 7, height: 7)
                            .padding(8)
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                            )
                            .shadow(radius: 5)
                        }
                        .offset(x: 30, y: -280)
                        .sheet(isPresented: $isShowingImage, onDismiss: loadImage) {
                            ImagePicker(image: $selectedImage)
                        }
                

                ZStack {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(maxWidth: .infinity, maxHeight: 50)
                        .offset(y: -200)
                        .edgesIgnoringSafeArea(.all)
                    
                    
                    List {
                        if isFilteredDist {
                            ForEach(filteredDistContacts){contact in
                                ContactView(contact: contact)
                            }
                            .background(RoundedRectangle(cornerRadius: 12).fill(.white))
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                        } else {
                            ForEach(filteredContacts){contact in
                                
                                ContactView(contact: contact)
                                
                            }
                            .background(RoundedRectangle(cornerRadius: 12).fill(.white))
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                        }
                    }
                    .listStyle(.insetGrouped)
                    .padding(.top, 180)
                    .listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                }
            }
            
            .overlay{
                HStack {
                    Button(action: {
                        isFiltered.toggle()
                        if isFiltered {
                            isFilteredDist = false
                        }
                    }) {
                        Image(systemName: "list.dash")
                            .foregroundColor(.white)
                    }
                    .frame(width: 44, height: 44)
                    .background(Color(red: 0.0, green: 0.3, blue: 0.0))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .offset(x:0, y:-200)
                    
                    Button(action: {
                        isFilteredDist.toggle()
                        if isFilteredDist {
                            isFiltered = false
                        }
                    }) {
                        Image(systemName: "star")
                            .foregroundColor(.white)
                    }
                    .frame(width: 44, height: 44)
                    .background(Color(red: 0.1, green: 0.3, blue: 0.1))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .offset(x:10, y:-200)
                    
                    NavigationLink(
                        destination: AddView(),
                        isActive: $isPresented,
                        label: {
                            Image(systemName: "person.fill.badge.plus")
                                .foregroundColor(.white)
                        })
                    .frame(width: 44, height: 44)
                    .background(Color(red: 0.1, green: 0.3, blue: 0.1))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .offset(x:20, y:-200)
                    
                    NavigationLink(destination: AssistantView()) {
                        Image(systemName: "waveform.and.mic")
                            .foregroundColor(.white)
                    }
                    .frame(width: 44, height: 44)
                    .background(Color(red: 0.1, green: 0.3, blue: 0.1))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .offset(x:30, y:-200)
                    .padding(.trailing)
                }
                
                
            }
        }
        
    }
    func loadImage() {
        guard let selectedImage = selectedImage else { return }

        if let profile = profiles.first {
            profile.picture = stringFromImage(selectedImage)
        } else {
            let profile = Profile(context: viewContext)
            profile.picture = stringFromImage(selectedImage)
        }

        do {
            try viewContext.save()
            print("Saved image to Core Data")
        } catch {
            print("Error saving image to Core Data: \(error.localizedDescription)")
        }
    }

}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}
