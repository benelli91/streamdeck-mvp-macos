import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: ProfileStore
    @EnvironmentObject private var deck: StreamDeckHID
    @State private var message: String?

    var body: some View {
        NavigationSplitView {
            List(selection: $store.selectedButtonID) {
                Section("Perfil") {
                    Label(store.profile.name, systemImage: "square.grid.3x3.fill")
                }
                Section("Botones") {
                    ForEach(store.profile.buttons.sorted { $0.index < $1.index }) { button in
                        Label(button.title, systemImage: button.symbol).tag(button.id)
                    }
                }
            }
            .navigationTitle("Stream Deck MVP")
            .frame(minWidth: 190)
        } content: {
            VStack(spacing: 16) {
                HStack {
                    Circle().fill(deck.connectedDeviceName == nil ? .orange : .green).frame(width: 10, height: 10)
                    Text(deck.connectedDeviceName ?? "Sin Stream Deck detectado")
                    Spacer()
                    Button("Permitir atajos") { ActionRunner.requestAccessibilityPermission() }
                }
                .font(.subheadline)
                .padding(.horizontal)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: store.profile.columns), spacing: 12) {
                    ForEach(0..<(store.profile.columns * store.profile.rows), id: \.self) { index in
                        let button = store.button(at: index)
                        DeckKey(button: button, selected: store.selectedButtonID == button.id) {
                            store.selectedButtonID = button.id
                            Task { await trigger(button) }
                        }
                    }
                }
                .padding(24)
                Spacer()
            }
            .navigationTitle(store.profile.name)
            .alert("No se pudo ejecutar", isPresented: Binding(get: { message != nil }, set: { if !$0 { message = nil } })) {
                Button("OK", role: .cancel) { message = nil }
            } message: { Text(message ?? "") }
        } detail: {
            if let id = store.selectedButtonID,
               let index = store.profile.buttons.firstIndex(where: { $0.id == id }) {
                ButtonEditor(button: $store.profile.buttons[index])
                    .frame(minWidth: 280)
            } else {
                ContentUnavailableView("Elegí un botón", systemImage: "cursorarrow.click")
            }
        }
        .task {
            deck.onButtonPressed = { index in
                let button = store.button(at: index)
                Task { await trigger(button) }
            }
        }
    }

    private func trigger(_ button: DeckButton) async {
        do { try await ActionRunner.run(button) }
        catch { message = error.localizedDescription }
    }
}

private struct DeckKey: View {
    let button: DeckButton
    let selected: Bool
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: button.symbol).font(.title2)
                Text(button.title).font(.caption).lineLimit(2).multilineTextAlignment(.center)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: 90)
            .background(Color(hex: button.colorHex))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(selected ? .white : .clear, lineWidth: 3))
        }
        .buttonStyle(.plain)
    }
}

private struct ButtonEditor: View {
    @Binding var button: DeckButton
    var body: some View {
        Form {
            Section("Aspecto") {
                TextField("Nombre", text: $button.title)
                TextField("Símbolo SF", text: $button.symbol)
                TextField("Color hex", text: $button.colorHex)
            }
            Section("Acción") {
                Picker("Tipo", selection: $button.action) {
                    ForEach(ButtonActionKind.allCases) { Text($0.rawValue).tag($0) }
                }
                if button.action != .none {
                    TextField(button.action == .shortcut ? "cmd+shift+p" : "URL", text: $button.value)
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle(button.title)
    }
}

private extension Color {
    init(hex: String) {
        let text = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        let value = UInt64(text, radix: 16) ?? 0x2F80ED
        self.init(red: Double((value >> 16) & 0xff) / 255, green: Double((value >> 8) & 0xff) / 255, blue: Double(value & 0xff) / 255)
    }
}
