import XCTest

@testable import PinataUI

final class CustomizationTests: XCTestCase {

  func testOnlySetKeysAreSent() throws {
    var customization = WalletCustomization()
    customization.ctaText = "Open the marketplace"
    customization.colorScheme.primaryColor = "#0055FF"
    let json = try XCTUnwrap(customization.toJSON())
    let colorScheme = try XCTUnwrap(json["colorScheme"] as? [String: Any])

    XCTAssertEqual(json["ctaText"] as? String, "Open the marketplace")
    XCTAssertEqual(colorScheme["primaryColor"] as? String, "#0055FF")
    XCTAssertNil(json["widgetTitle"])
    XCTAssertNil(json["description"])
    XCTAssertNil(colorScheme["walletColor"])
  }

  func testEmptyCustomizationSerializesToNil() {
    XCTAssertNil(WalletCustomization().toJSON())
    XCTAssertNil(PreviewCustomization().toJSON())
    XCTAssertTrue(FullShoppingCustomization().toJSON().isEmpty)
  }

  func testWalletDescriptionNeedsItsOwnObject() throws {
    var customization = WalletCustomization()
    customization.descriptionCopy = "How do points work?"
    customization.descriptionUrl = "example.com/faq"
    let description = try XCTUnwrap(customization.toJSON()?["description"] as? [String: Any])

    XCTAssertEqual(description["copy"] as? String, "How do points work?")
    XCTAssertEqual(description["url"] as? String, "example.com/faq")
  }

  func testCurrencyUsesTheWebContractValue() {
    var customization = PreviewCustomization()
    customization.currency = .dollar
    XCTAssertEqual(customization.toJSON()?["currency"] as? String, "dollar")
  }

  func testFullShoppingDetailsColorsAreFlattenedToTheRoot() {
    var customization = FullShoppingCustomization()
    customization.widgetTitle = "Shop"
    customization.detailsColors.detailsActionColor = "#111111"
    let json = customization.toJSON()

    XCTAssertEqual(json["detailsActionColor"] as? String, "#111111")
    XCTAssertNil(json["detailsColors"])
  }

  func testNestedLabelsSerializePerSection() throws {
    var customization = FullShoppingCustomization()
    customization.labels.walletCard.accessAccountCta = "Go to Pinata"
    customization.labels.browseMarketplace.searchPlaceholder = "Search deals"
    let labels = try XCTUnwrap(customization.toJSON()["labels"] as? [String: Any])

    XCTAssertEqual((labels["walletCard"] as? [String: Any])?["accessAccountCta"] as? String, "Go to Pinata")
    XCTAssertEqual((labels["browseMarketplace"] as? [String: Any])?["searchPlaceholder"] as? String, "Search deals")
    XCTAssertNil(labels["featured"])
  }

  func testRenterAttributesSerializeUnderAttributes() throws {
    var customization = PreviewCustomization()
    customization.attributes.zipCode = "33130"
    let json = try XCTUnwrap(customization.toJSON())

    XCTAssertEqual((json["attributes"] as? [String: Any])?["zipCode"] as? String, "33130")
    XCTAssertEqual(json.count, 1)
  }
}
