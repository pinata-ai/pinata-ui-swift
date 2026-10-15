import SafariServices
import SwiftUI
import WebKit

/// Bare WKWebView around the demo page. Messages the iframes post to the top window and
/// top-level redirects reach the app through `onEvent`, the way the SDK callbacks will.
struct DemoWebView: UIViewRepresentable {
  let url: URL
  let onEvent: (String) -> Void

  func makeCoordinator() -> Coordinator { Coordinator(host: url.host, onEvent: onEvent) }

  func makeUIView(context: Context) -> WKWebView {
    let config = WKWebViewConfiguration()
    // Deals, account settings and "open marketplace" use window.open(); without this they are dropped.
    config.preferences.javaScriptCanOpenWindowsAutomatically = true
    // The iframes post messages to the top window (e.g. "pinata-preview-browse-marketplace"); forward them here.
    config.userContentController.add(context.coordinator, name: "PinataBridge")
    config.userContentController.addUserScript(WKUserScript(
      source: "addEventListener('message', e => webkit.messageHandlers.PinataBridge.postMessage(JSON.stringify(e.data)))",
      injectionTime: .atDocumentEnd, forMainFrameOnly: true))

    let webView = WKWebView(frame: .zero, configuration: config)
    webView.navigationDelegate = context.coordinator
    webView.uiDelegate = context.coordinator
    webView.allowsBackForwardNavigationGestures = true
    if #available(iOS 16.4, *) { webView.isInspectable = true }  // Safari > Develop
    context.coordinator.webView = webView
    webView.load(URLRequest(url: url))
    return webView
  }

  func updateUIView(_ webView: WKWebView, context: Context) {}

  final class Coordinator: NSObject, WKScriptMessageHandler, WKNavigationDelegate, WKUIDelegate {
    weak var webView: WKWebView?
    private let host: String?
    private let onEvent: (String) -> Void
    /// Web views handed to window.open(); kept alive until their first navigation is intercepted.
    private var popups: [WKWebView] = []

    init(host: String?, onEvent: @escaping (String) -> Void) {
      self.host = host
      self.onEvent = onEvent
    }

    func userContentController(_ controller: WKUserContentController, didReceive message: WKScriptMessage) {
      onEvent("Event received: \(message.body)")
    }

    /// Opens every window.open() target in SFSafariViewController instead of a second web view.
    func webView(
      _ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration,
      for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
      let popup = WKWebView(frame: .zero, configuration: configuration)
      popup.navigationDelegate = self
      popups.append(popup)
      return popup
    }

    /// Popups go to Safari; top-level redirects (ctaUrlRedirect, urlRedirect) are shown instead of leaving the demo page.
    func webView(
      _ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
      decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
      guard let url = navigationAction.request.url, navigationAction.targetFrame?.isMainFrame != false else {
        return decisionHandler(.allow)
      }
      if popups.contains(webView) {
        guard url.scheme?.hasPrefix("http") == true else { return decisionHandler(.allow) }  // about:blank
        popups.removeAll { $0 == webView }
        self.webView?.window?.rootViewController?.present(SFSafariViewController(url: url), animated: true)
        return decisionHandler(.cancel)
      }
      if url.host == host { return decisionHandler(.allow) }
      onEvent("Redirect intercepted: \(url)")
      decisionHandler(.cancel)
    }
  }
}
