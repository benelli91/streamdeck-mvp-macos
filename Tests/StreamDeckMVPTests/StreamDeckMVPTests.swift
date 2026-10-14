import XCTest
@testable import StreamDeckMVP

final class StreamDeckMVPTests: XCTestCase {
    func testStarterProfileHas15Buttons() {
        XCTAssertEqual(DeckProfile.starter.buttons.count, 15)
        XCTAssertEqual(DeckProfile.starter.buttons.map(\.index), Array(0..<15))
    }
}
