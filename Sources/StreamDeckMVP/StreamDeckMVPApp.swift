import SwiftUI

@main
struct StreamDeckMVPApp: App {
    @StateObject private var store = ProfileStore()
    @StateObject private var deck = StreamDeckHID()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .environmentObject(deck)
        }
        .defaultSize(width: 1100, height: 680)
    }
}
