// MARK: - ContentView
//
// This view represents the main content of the app, which is a tab view with several subviews.
// It includes an @ObservedObject for the NotificationManager and the PlanData shared instance.
// The NotificationManager is initialized with fetchedContacts from Core Data.
// The onAppear() function is used to request notification permissions and load plan data from JSON.


import SwiftUI
import CoreData

struct ContentView: View {
    
    @ObservedObject private var notificationManager: NotificationManager
    @ObservedObject var planData = PlanData.shared
    
    init() {
        let request = NSFetchRequest<Contacts>(entityName: "Contacts")
        request.sortDescriptors = []
        let fetchedContacts = try? PersistenceController.shared.container.viewContext.fetch(request)

        _notificationManager = ObservedObject(wrappedValue: NotificationManager(contacts: fetchedContacts ?? []))
    }

    
    var body: some View {
        TabView {
            MainView()
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("Contacts")
                }
            

            MapView()
                .tabItem {
                    Image(systemName: "globe")
                    Text("Map")
                }
            MakePlanView()
                .tabItem {
                    Image(systemName: "airplane")
                    Text("Plan") // temporary name
            }
            CalendarView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Calendar")
            }
            
            SearchView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Search") // temporary name
                }
            
            
            
        }
        .onAppear{
            //request noti permission when opening the app for the first rime
            requestNotiPermission()
            if self.planData.loadPlanJSON() == false {
                print("Could not load the JSON file of plans")
            }
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}
