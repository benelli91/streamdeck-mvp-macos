import Foundation
import SwiftUI

@MainActor
final class ProfileStore: ObservableObject {
    @Published var profile: DeckProfile { didSet { save() } }
    @Published var selectedButtonID: UUID?

    private let fileURL: URL

    init(fileManager: FileManager = .default) {
        let folder = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("StreamDeckMVP", isDirectory: true)
        try? fileManager.createDirectory(at: folder, withIntermediateDirectories: true)
        fileURL = folder.appendingPathComponent("profile.json")
        if let data = try? Data(contentsOf: fileURL),
           let saved = try? JSONDecoder().decode(DeckProfile.self, from: data) {
            profile = saved
        } else {
            profile = .starter
        }
        selectedButtonID = profile.buttons.first?.id
    }

    func button(at index: Int) -> DeckButton {
        profile.buttons.first(where: { $0.index == index }) ?? .placeholder(index: index)
    }

    func update(_ button: DeckButton) {
        guard let index = profile.buttons.firstIndex(where: { $0.id == button.id }) else { return }
        profile.buttons[index] = button
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(profile) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
