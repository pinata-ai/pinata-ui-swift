import SwiftUI

/// Throwaway mock, not the SDK: a bare WKWebView around the Partner UI Demo Site, to show
/// the marketplace components running inside a native iOS app and the events reaching it.
@main
struct PinataUIMockApp: App {
  /// Page the mock loads. `component` accepts marketplace-small (wallet), marketplace-large (preview) and fullshop.
  static let demoURL = URL(string: "https://dev-demo.pinata.ai/01JVTCBCEHNZC48XV820PRS0YM?component=marketplace-small")!

  var body: some Scene {
    WindowGroup { ContentView() }
  }
}

struct ContentView: View {
  @State private var toast: String?

  var body: some View {
    DemoWebView(url: PinataUIMockApp.demoURL) { toast = $0 }
      .ignoresSafeArea(edges: .bottom)
      .overlay(alignment: .bottom) {
        if let toast {
          Text(toast)
            .font(.footnote)
            .padding(12)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
            .padding()
            .task(id: toast) {
              try? await Task.sleep(for: .seconds(3))
              self.toast = nil
            }
        }
      }
  }
}
