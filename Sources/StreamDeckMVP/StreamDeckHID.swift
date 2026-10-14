import Combine
import Foundation
@preconcurrency import IOKit.hid

/// Detects Elgato USB HID devices and forwards the conventional button report to the app.
/// The output-image protocol varies by model, so this MVP deliberately keeps it isolated
/// until the exact hardware model is selected.
final class StreamDeckHID: ObservableObject {
    @Published private(set) var connectedDeviceName: String?
    var onButtonPressed: ((Int) -> Void)?

    private let manager: IOHIDManager
    private var previousStates: [Bool] = []

    init() {
        manager = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))
        let matching: [[String: Any]] = [[kIOHIDVendorIDKey as String: 0x0FD9]]
        IOHIDManagerSetDeviceMatchingMultiple(manager, matching as CFArray)
        IOHIDManagerRegisterDeviceMatchingCallback(manager, { context, _, _, device in
            guard let context, let device else { return }
            let owner = Unmanaged<StreamDeckHID>.fromOpaque(context).takeUnretainedValue()
            let name = IOHIDDeviceGetProperty(device, kIOHIDProductKey as CFString) as? String ?? "Stream Deck"
            DispatchQueue.main.async { owner.connectedDeviceName = name }
        }, Unmanaged.passUnretained(self).toOpaque())
        IOHIDManagerRegisterDeviceRemovalCallback(manager, { context, _, _, _ in
            guard let context else { return }
            let owner = Unmanaged<StreamDeckHID>.fromOpaque(context).takeUnretainedValue()
            DispatchQueue.main.async { owner.connectedDeviceName = nil }
        }, Unmanaged.passUnretained(self).toOpaque())
        IOHIDManagerRegisterInputValueCallback(manager, { context, _, _, value in
            guard let context, let value else { return }
            let owner = Unmanaged<StreamDeckHID>.fromOpaque(context).takeUnretainedValue()
            owner.consume(value)
        }, Unmanaged.passUnretained(self).toOpaque())
        IOHIDManagerScheduleWithRunLoop(manager, CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue)
        IOHIDManagerOpen(manager, IOOptionBits(kIOHIDOptionsTypeNone))
    }

    private func consume(_ value: IOHIDValue) {
        // Button elements report 1 when pressed. This works for the standard HID usage-page
        // representation; model-specific report parsing can be added beside this method.
        let element = IOHIDValueGetElement(value)
        guard IOHIDElementGetUsagePage(element) == 0x09, IOHIDValueGetIntegerValue(value) == 1 else { return }
        let usage = Int(IOHIDElementGetUsage(element))
        guard usage > 0 else { return }
        DispatchQueue.main.async { [weak self] in self?.onButtonPressed?(usage - 1) }
    }
}
