//
//  EngEnApp.swift
//  EngEn
//
//  Created by Loaner on 3/21/23.
//

import SwiftUI

@main
struct EngEnApp: App {
    let persistenceController = PersistenceController.shared
    @State private var isLoading = true
    
    var body: some Scene {
        WindowGroup {
            if isLoading {
                LoadingView()
                    .onAppear {
                        // Load data from JSON to Core Data
                        loadJsonGeoData()
                        importJsonConData()
                        
                        // Set isLoading to false once data is loaded
                        isLoading = false
                    }
            } else {
                ContentView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            }
        }
    }
}
