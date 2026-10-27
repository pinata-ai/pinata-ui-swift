import UIKit
import XCTest

@testable import PinataUI

final class LifecycleTests: XCTestCase {

  func testLeavingTheWindowKeepsTheViewUsable() {
    let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    let screen = UIView(frame: window.bounds)
    let view = PinataMarketplaceWalletView(frame: window.bounds)
    screen.addSubview(view)
    window.addSubview(screen)
    var errors: [String] = []
    view.onError = { errors.append($0) }

    screen.removeFromSuperview()  // like a screen pushed over this one
    XCTAssertNil(view.window)
    view.load()

    XCTAssertEqual(errors, [])
    XCTAssertNotNil(view.webView.superview)
  }

  func testRemovingTheViewDestroysIt() {
    let screen = UIView()
    let view = PinataMarketplaceWalletView()
    screen.addSubview(view)
    var errors: [String] = []
    view.onError = { errors.append($0) }

    view.removeFromSuperview()
    view.load()

    XCTAssertEqual(errors.count, 1)
    XCTAssertTrue(errors.first?.contains("create a new instance") == true, errors.description)
    XCTAssertNil(view.webView.superview)
  }
}
