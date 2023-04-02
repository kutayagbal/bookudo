//
//  bookudoApp.swift
//  bookudo
//
//  Created by Kutay Agbal on 2.04.2023.
//

import SwiftUI

@main
struct bookudoApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            SplashView().environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
