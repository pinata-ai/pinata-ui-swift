import XCTest

@testable import PinataUI

final class MarketplaceOpenEventTests: XCTestCase {

  func testParsesTheFullPayload() {
    let event = MarketplaceOpenEvent.fromJSON([
      "type": "pinata-marketplace-open", "source": "preview", "authenticated": true,
      "detailsId": "01ABC", "detailsType": "deal", "entryPoint": "winner_banner",
    ])

    XCTAssertEqual(event.source, "preview")
    XCTAssertTrue(event.authenticated)
    XCTAssertEqual(event.detailsId, "01ABC")
    XCTAssertEqual(event.detailsType, "deal")
    XCTAssertEqual(event.entryPoint, "winner_banner")
  }

  func testMissingOptionalsComeBackNil() {
    let event = MarketplaceOpenEvent.fromJSON([
      "type": "pinata-marketplace-open", "source": "wallet", "authenticated": false,
    ])

    XCTAssertEqual(event.source, "wallet")
    XCTAssertFalse(event.authenticated)
    XCTAssertNil(event.detailsId)
    XCTAssertNil(event.detailsType)
    XCTAssertNil(event.entryPoint)
  }
}
