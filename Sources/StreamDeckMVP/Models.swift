import Foundation

enum ButtonActionKind: String, Codable, CaseIterable, Identifiable {
    case shortcut = "Atajo"
    case url = "Abrir URL"
    case webhook = "Webhook"
    case none = "Sin acción"

    var id: String { rawValue }
}

struct DeckButton: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    var index: Int
    var title: String
    var symbol: String
    var action: ButtonActionKind
    var value: String
    var colorHex: String

    static func placeholder(index: Int) -> DeckButton {
        DeckButton(index: index, title: "Botón \(index + 1)", symbol: "circle", action: .none, value: "", colorHex: "2F80ED")
    }
}

struct DeckProfile: Codable, Identifiable {
    var id: UUID = UUID()
    var name: String
    var columns: Int
    var rows: Int
    var buttons: [DeckButton]

    static let starter = DeckProfile(
        name: "Perfil principal",
        columns: 5,
        rows: 3,
        buttons: [
            DeckButton(index: 0, title: "Navegador", symbol: "safari", action: .url, value: "https://www.google.com", colorHex: "007AFF"),
            DeckButton(index: 1, title: "Webhook", symbol: "bolt.fill", action: .webhook, value: "https://example.com/hook", colorHex: "FF9500")
        ] + (2..<15).map(DeckButton.placeholder)
    )
}
