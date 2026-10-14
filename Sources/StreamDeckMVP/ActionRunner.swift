import AppKit
import ApplicationServices
import Foundation

enum ActionRunner {
    static func run(_ button: DeckButton) async throws {
        switch button.action {
        case .none:
            return
        case .url:
            guard let url = URL(string: button.value) else { throw ActionError.invalidURL }
            NSWorkspace.shared.open(url)
        case .webhook:
            guard let url = URL(string: button.value) else { throw ActionError.invalidURL }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            _ = try await URLSession.shared.data(for: request)
        case .shortcut:
            guard AXIsProcessTrusted() else { throw ActionError.accessibilityPermissionRequired }
            try sendShortcut(button.value)
        }
    }

    static func requestAccessibilityPermission() {
        let key = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
        AXIsProcessTrustedWithOptions([key: true] as CFDictionary)
    }

    private static func sendShortcut(_ shortcut: String) throws {
        let pieces = shortcut.lowercased().split(separator: "+").map(String.init)
        guard let key = pieces.last, key.count == 1,
              let scalar = key.unicodeScalars.first,
              let event = CGEvent(keyboardEventSource: nil, virtualKey: virtualKey(for: scalar), keyDown: true)
        else { throw ActionError.invalidShortcut }
        var flags: CGEventFlags = []
        if pieces.contains("cmd") || pieces.contains("command") { flags.insert(.maskCommand) }
        if pieces.contains("shift") { flags.insert(.maskShift) }
        if pieces.contains("alt") || pieces.contains("option") { flags.insert(.maskAlternate) }
        if pieces.contains("ctrl") || pieces.contains("control") { flags.insert(.maskControl) }
        event.flags = flags
        event.post(tap: .cghidEventTap)
        let up = CGEvent(keyboardEventSource: nil, virtualKey: virtualKey(for: scalar), keyDown: false)
        up?.flags = flags
        up?.post(tap: .cghidEventTap)
    }

    // Key codes for the standard Latin Mac keyboard layout.
    private static func virtualKey(for scalar: UnicodeScalar) -> CGKeyCode {
        let keys: [Character: CGKeyCode] = [
            "a": 0, "s": 1, "d": 2, "f": 3, "h": 4, "g": 5, "z": 6, "x": 7, "c": 8, "v": 9,
            "b": 11, "q": 12, "w": 13, "e": 14, "r": 15, "y": 16, "t": 17, "1": 18, "2": 19,
            "3": 20, "4": 21, "6": 22, "5": 23, "=": 24, "9": 25, "7": 26, "-": 27, "8": 28,
            "0": 29, "]": 30, "o": 31, "u": 32, "[": 33, "i": 34, "p": 35, "l": 37, "j": 38,
            "'": 39, "k": 40, ";": 41, "\\": 42, ",": 43, "/": 44, "n": 45, "m": 46, ".": 47
        ]
        return keys[Character(String(scalar).lowercased())] ?? 0
    }
}

enum ActionError: LocalizedError {
    case invalidURL, invalidShortcut, accessibilityPermissionRequired
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "La URL no es válida."
        case .invalidShortcut: return "Usá atajos como cmd+shift+p."
        case .accessibilityPermissionRequired: return "Habilitá Accesibilidad para esta app en Configuración del Sistema."
        }
    }
}
