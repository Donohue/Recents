import SwiftUI

@main
struct RecentsApp: App {
    @StateObject private var contactsStore = ContactsStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(contactsStore)
        }
    }
}
