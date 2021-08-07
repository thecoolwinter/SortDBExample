//
//  SortDBExampleApp.swift
//  SortDBExample
//
//  Created by Khan Winter on 8/7/21.
//

import SwiftUI

@main
struct SortDBExampleApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
