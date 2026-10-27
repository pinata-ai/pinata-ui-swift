import XCTest

@testable import PinataUI

final class HostPageTests: XCTestCase {

  func testEventModeAddsTheNavigationModeFlag() {
    let json = HostPage.buildCustomization(extra: [:], component: nil, eventMode: true, companyName: nil)
    XCTAssertEqual(json["navigationMode"] as? String, "events")
  }

  func testFullShoppingDoesNotGetTheFlag() {
    let json = HostPage.buildCustomization(extra: [:], component: nil, eventMode: false, companyName: nil)
    XCTAssertNil(json["navigationMode"])
  }

  func testTypedCustomizationWinsOverTheExtraEscapeHatch() {
    let json = HostPage.buildCustomization(
      extra: ["ctaText": "from extra", "untypedKey": 1],
      component: ["ctaText": "from typed"],
      eventMode: true, companyName: nil)

    XCTAssertEqual(json["ctaText"] as? String, "from typed")
    XCTAssertEqual(json["untypedKey"] as? Int, 1)
  }

  func testCompanyNamePropertyFillsOnlyWhenCustomizationMissesIt() {
    let fromTyped = HostPage.buildCustomization(
      extra: [:], component: ["companyName": "typed"], eventMode: true, companyName: "prop")
    XCTAssertEqual(fromTyped["companyName"] as? String, "typed")

    let fromProp = HostPage.buildCustomization(extra: [:], component: nil, eventMode: true, companyName: "prop")
    XCTAssertEqual(fromProp["companyName"] as? String, "prop")
  }

  func testDevEnvironmentSetsTheElementAttributeProductionDoesNot() {
    XCTAssertTrue(
      HostPage.buildElementAttributes(environment: .dev, userToken: nil, customization: [:])
        .contains(" environment=\"dev\""))
    XCTAssertFalse(
      HostPage.buildElementAttributes(environment: .production, userToken: nil, customization: [:])
        .contains("environment="))
  }

  func testUserTokenIsEscapedForTheAttribute() {
    let attributes = HostPage.buildElementAttributes(
      environment: .production, userToken: "a\"b'c&d", customization: [:])
    XCTAssertTrue(attributes.contains("usertoken=\"a&quot;b&#39;c&amp;d\""))
  }

  func testCustomizationJsonIsEscapedInsideSingleQuotes() {
    let attributes = HostPage.buildElementAttributes(
      environment: .production, userToken: nil, customization: ["ctaText": "Gabriel's deals"])
    XCTAssertTrue(
      attributes.contains("customization='{&quot;ctaText&quot;:&quot;Gabriel&#39;s deals&quot;}'"), attributes)
  }

  func testEscapeHandlesTheAmpersandFirst() {
    XCTAssertEqual(HostPage.escapeAttribute("&'\""), "&amp;&#39;&quot;")
  }

  func testHostPageWiresTheScriptTheComponentAndTheBridge() {
    let page = HostPage.buildHostPage(
      scriptURL: URL(string: "https://static.pinata.ai/x.js")!,
      componentTag: "pinata-marketplace-wallet", elementAttributes: " usertoken=\"t\"")

    XCTAssertTrue(page.contains("<script type=\"module\" src=\"https://static.pinata.ai/x.js\"></script>"))
    XCTAssertTrue(
      page.contains(
        "<pinata-marketplace-wallet style=\"display:block;height:100vh\" usertoken=\"t\"></pinata-marketplace-wallet>"))
    XCTAssertTrue(
      page.contains(
        "addEventListener(\"message\", e => webkit.messageHandlers.PinataBridge.postMessage(JSON.stringify(e.data)))"))
    XCTAssertTrue(page.contains("pinata-error"))
  }

  func testSlashesInValuesAreNotEscaped() {
    XCTAssertEqual(HostPage.serialize(["url": "https://example.com/faq"]), "{\"url\":\"https://example.com/faq\"}")
  }

  func testErrorDetailKeepsStringsAndSerializesObjects() {
    XCTAssertEqual(PinataComponentView.errorDetail("Error handoff token"), "Error handoff token")
    XCTAssertEqual(
      PinataComponentView.errorDetail(["name": "NetworkError", "statusCode": 401]),
      "{\"name\":\"NetworkError\",\"statusCode\":401}")
    XCTAssertEqual(PinataComponentView.errorDetail(nil), "")
    XCTAssertEqual(PinataComponentView.errorDetail(NSNull()), "")
  }
}
