import SwiftUI

@main

struct FrootyNator_Juice_MasterApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            NavigationView {
                LoadingScreenView()
            }
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
