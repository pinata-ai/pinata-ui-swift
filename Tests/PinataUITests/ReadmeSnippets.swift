// The Swift code blocks of README.md, verbatim, so the integration guide always compiles.
// `ReadmeSnippetsTests` checks that every block in the README appears in this file as is,
// which is why the imports repeat and the last snippet sits at column 0 inside its wrapper.

import PinataUI
import UIKit

final class WalletViewController: UIViewController {
  var token: String?  // nil for renters who are not on Piñata yet

  override func viewDidLoad() {
    super.viewDidLoad()
    let wallet = PinataMarketplaceWalletView(frame: view.bounds)
    wallet.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    wallet.environment = .sandbox
    wallet.userToken = token
    wallet.customization.companyName = "your-company"
    wallet.onMarketplaceOpen = { [weak self] event in
      if event.authenticated { self?.openFullShopping(event) } else { self?.startOnboarding() }
    }
    wallet.onError = { message in print("Pinata: \(message)") }
    view.addSubview(wallet)
    wallet.load()
  }

  func openFullShopping(_ event: MarketplaceOpenEvent) {
    let screen = UIViewController()
    let fullShopping = PinataFullShoppingView(frame: screen.view.bounds)
    fullShopping.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    fullShopping.environment = .sandbox
    fullShopping.userToken = token  // required
    fullShopping.detailsId = event.detailsId  // nil opens the marketplace home
    fullShopping.detailsType = event.detailsType
    screen.view.addSubview(fullShopping)
    navigationController?.pushViewController(screen, animated: true)
    fullShopping.load()
  }

  func startOnboarding() {
    // The renter has no Piñata account yet: create it through your backend integration,
    // then show the Wallet again with their userToken.
  }
}

import PinataUI
import SwiftUI

struct WalletScreen: UIViewRepresentable {
  let token: String?
  let onMarketplaceOpen: (MarketplaceOpenEvent) -> Void

  func makeUIView(context: Context) -> PinataMarketplaceWalletView {
    let wallet = PinataMarketplaceWalletView()
    wallet.environment = .sandbox
    wallet.userToken = token
    wallet.onMarketplaceOpen = onMarketplaceOpen
    wallet.load()
    return wallet
  }

  func updateUIView(_ uiView: PinataMarketplaceWalletView, context: Context) {}
}

func customizationSnippet(wallet: PinataMarketplaceWalletView) {
wallet.customization.ctaText = "Browse marketplace"
wallet.customization.colorScheme.primaryColor = "#0055FF"
}
