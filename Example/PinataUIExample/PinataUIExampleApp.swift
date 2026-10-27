import PinataUI
import SwiftUI

/// Demo of the V2 flow: Wallet or Preview emits `pinata-marketplace-open`, the app reacts
/// and shows Full Shopping on the clicked item. Token and environment come from the scheme's
/// environment variables (see project.yml).
@main
struct PinataUIExampleApp: App {
  var body: some Scene {
    WindowGroup { ContentView() }
  }
}

enum Demo {
  static let environment: PinataEnvironment =
    PinataEnvironment(rawValue: (ProcessInfo.processInfo.environment["PINATA_DEMO_ENV"] ?? "dev").lowercased()) ?? .dev
  static let token: String? = ProcessInfo.processInfo.environment["PINATA_DEMO_TOKEN"].flatMap { $0.isEmpty ? nil : $0 }
}

enum Screen: Hashable {
  case walletAnonymous, walletLoggedIn, previewLoggedIn
  case fullShopping(detailsId: String?, detailsType: String?)

  var title: String {
    switch self {
    case .walletAnonymous: return "Wallet anonymous"
    case .walletLoggedIn: return "Wallet logged in"
    case .previewLoggedIn: return "Preview logged in"
    case .fullShopping: return "Full Shopping"
    }
  }
}

struct ContentView: View {
  @State private var selected: Screen = .walletAnonymous
  @State private var path: [Screen] = []
  @State private var toast: String?

  var body: some View {
    NavigationStack(path: $path) {
      VStack(spacing: 0) {
        Picker("Component", selection: $selected) {
          ForEach([Screen.walletAnonymous, .walletLoggedIn, .previewLoggedIn], id: \.self) { Text($0.title) }
        }
        .pickerStyle(.segmented)
        .padding()
        componentView(for: selected).id(selected)  // single-use views: a new one per selection
      }
      .navigationTitle(selected.title)
      .navigationDestination(for: Screen.self) { screen in
        componentView(for: screen).navigationTitle(screen.title)
      }
    }
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

  @ViewBuilder
  private func componentView(for screen: Screen) -> some View {
    switch screen {
    case .walletAnonymous:
      PinataComponent {
        let view = PinataMarketplaceWalletView()
        // Exercises the typed customization end to end.
        view.customization.ctaText = "Open the marketplace"
        view.customization.colorScheme.primaryColor = "#0A7E5C"
        return configured(view, userToken: nil)
      }
    case .walletLoggedIn:
      PinataComponent { configured(PinataMarketplaceWalletView(), userToken: Demo.token) }
    case .previewLoggedIn:
      PinataComponent { configured(PinataMarketplacePreviewView(), userToken: Demo.token) }
    case .fullShopping(let detailsId, let detailsType):
      if Demo.token == nil {
        // A real app would onboard the user here (authenticated=false) before opening the marketplace.
        Text("No PINATA_DEMO_TOKEN set; cannot open Full Shopping").padding()
      } else {
        PinataComponent {
          let view = PinataFullShoppingView()
          view.detailsId = detailsId
          view.detailsType = detailsType
          return configured(view, userToken: Demo.token)
        }
      }
    }
  }

  private func configured(_ view: PinataComponentView, userToken: String?) -> PinataComponentView {
    view.environment = Demo.environment
    view.userToken = userToken
    view.companyName = "your-company"
    view.onMarketplaceOpen = { event in
      toast = "Event received: \(event)"
      path.append(.fullShopping(detailsId: event.detailsId, detailsType: event.detailsType))
    }
    view.onError = { message in toast = "pinata-error: \(message)" }
    view.onDetailsConsumed = { toast = "Deep link consumed" }
    return view
  }
}

/// The SDK views are plain UIViews; this is all SwiftUI needs.
struct PinataComponent: UIViewRepresentable {
  let make: () -> PinataComponentView

  func makeUIView(context: Context) -> PinataComponentView {
    let view = make()
    view.load()
    return view
  }

  func updateUIView(_ uiView: PinataComponentView, context: Context) {}
}
