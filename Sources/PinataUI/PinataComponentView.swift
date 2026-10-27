import SafariServices
import UIKit
import WebKit

/// Base of every Pinata component view: a `WKWebView` around a generated host page with the
/// pinata-ui script and one web component. The host page forwards every `message` from the
/// component's iframes to native (registered once, here), and `window.open` targets
/// (deals, full Pinata account) open in `SFSafariViewController`.
///
/// Configure the properties, then call `load()`. The component reads them on load only;
/// to change them afterwards, set and call `load()` again.
open class PinataComponentView: UIView {

  var componentTag: String { fatalError("Subclasses define the web component tag") }
  /// Wallet and Preview get `navigationMode: "events"`; Full Shopping is the destination.
  var usesEventMode: Bool { true }

  public var environment: PinataEnvironment = .production
  public var userToken: String?
  public var companyName: String?
  /// Escape hatch for `customization` keys the SDK does not type.
  public var extraCustomization: [String: Any] = [:]
  public var onMarketplaceOpen: ((MarketplaceOpenEvent) -> Void)?
  public var onError: ((String) -> Void)?

  let webView: WKWebView = {
    let configuration = WKWebViewConfiguration()
    // Deals and "Access your full Pinata account" use window.open(); without this they are dropped.
    configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
    return WKWebView(frame: .zero, configuration: configuration)
  }()

  private let bridge = Bridge()
  /// Web views handed to window.open(); kept until their first navigation is sent to Safari.
  fileprivate var popups: [WKWebView] = []

  public override init(frame: CGRect) {
    super.init(frame: frame)
    setUp()
  }

  public required init?(coder: NSCoder) {
    super.init(coder: coder)
    setUp()
  }

  private func setUp() {
    bridge.view = self
    webView.configuration.userContentController.add(bridge, name: "PinataBridge")
    webView.navigationDelegate = bridge
    webView.uiDelegate = bridge
    webView.frame = bounds
    webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    addSubview(webView)
    #if DEBUG
      if #available(iOS 16.4, *) { webView.isInspectable = true }  // Safari > Develop
    #endif
  }

  public func load() {
    webView.loadHTMLString(buildHostPage(), baseURL: environment.baseURL)
  }

  fileprivate func handleBridgeMessage(_ data: String) {
    guard data.hasPrefix("{"),
      let object = try? JSONSerialization.jsonObject(with: Data(data.utf8)) as? [String: Any]
    else { return }
    switch object["type"] as? String {
    case "pinata-marketplace-open":
      onMarketplaceOpen?(.fromJSON(object))
    case "pinata-error":
      onError?(object["detail"] as? String ?? "")
    default:
      break
    }
  }

  /// Opens a page outside the component (a deal, the full Pinata account) in Safari.
  fileprivate func openExternally(_ url: URL) {
    if let presenter = presentingViewController {
      presenter.present(SFSafariViewController(url: url), animated: true)
    } else {
      UIApplication.shared.open(url)
    }
  }

  private var presentingViewController: UIViewController? {
    var responder: UIResponder? = self
    while let current = responder {
      if let controller = current as? UIViewController {
        var top = controller
        while let presented = top.presentedViewController { top = presented }
        return top
      }
      responder = current.next
    }
    return nil
  }

  /// The view's typed `customization`, serialized; nil when nothing was set.
  func componentCustomization() -> [String: Any]? { nil }

  func buildCustomization() -> [String: Any] {
    HostPage.buildCustomization(
      extra: extraCustomization, component: componentCustomization(),
      eventMode: usesEventMode, companyName: companyName)
  }

  func elementAttributes() -> String {
    HostPage.buildElementAttributes(
      environment: environment, userToken: userToken, customization: buildCustomization())
  }

  private func buildHostPage() -> String {
    HostPage.buildHostPage(
      scriptURL: environment.scriptURL, componentTag: componentTag, elementAttributes: elementAttributes())
  }
}

/// The web view's delegates, kept out of the view so `WKUserContentController` (which retains
/// its message handlers) never retains the view.
private final class Bridge: NSObject, WKScriptMessageHandler, WKNavigationDelegate, WKUIDelegate {

  weak var view: PinataComponentView?

  func userContentController(_ controller: WKUserContentController, didReceive message: WKScriptMessage) {
    guard let data = message.body as? String else { return }
    view?.handleBridgeMessage(data)
  }

  /// Hands window.open() a web view whose first navigation goes to Safari.
  func webView(
    _ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration,
    for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures
  ) -> WKWebView? {
    let popup = WKWebView(frame: .zero, configuration: configuration)
    popup.navigationDelegate = self
    view?.popups.append(popup)
    return popup
  }

  func webView(
    _ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
    decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
  ) {
    guard let view, let url = navigationAction.request.url else { return decisionHandler(.allow) }
    if view.popups.contains(webView) {
      guard url.scheme?.hasPrefix("http") == true else { return decisionHandler(.allow) }  // about:blank
      view.popups.removeAll { $0 == webView }
      view.openExternally(url)
      return decisionHandler(.cancel)
    }
    // The component's iframes navigate freely; only the host page itself stays in the view.
    guard navigationAction.targetFrame?.isMainFrame != false else { return decisionHandler(.allow) }
    if url.host == view.environment.baseURL.host, url.path.isEmpty || url.path == "/" {
      return decisionHandler(.allow)
    }
    view.openExternally(url)
    decisionHandler(.cancel)
  }
}
