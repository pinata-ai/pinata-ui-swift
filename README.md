# pinata-ui-swift

iOS SDK for the Piñata marketplace components. Each component is a native `UIView` that renders
the Piñata web component in a `WKWebView` and delivers its events to your app as typed callbacks.
It is the native counterpart of [pinata-ui-react-native](https://github.com/pinata-ai/pinata-ui-react-native)
and the twin of [pinata-ui-kotlin](https://github.com/pinata-ai/pinata-ui-kotlin).

[Partner API reference](https://www.pinata.ai/partners/api/v1/redoc/)

## Installation

Requires iOS 15 or higher. The package is distributed with Swift Package Manager, straight from
this repository.

In Xcode: File > Add Package Dependencies, enter `https://github.com/pinata-ai/pinata-ui-swift`,
keep the rule "Up to Next Major Version" from `0.1.0`, and add the `PinataUI` product to your app
target.

In a `Package.swift`:

```swift
// Package.swift
dependencies: [
  .package(url: "https://github.com/pinata-ai/pinata-ui-swift.git", from: "0.1.0")
],
targets: [
  .target(name: "YourApp", dependencies: [.product(name: "PinataUI", package: "pinata-ui-swift")])
]
```

Then `import PinataUI` where you use the views.

## Components

| View | Web component | `userToken` |
| --- | --- | --- |
| `PinataMarketplaceWalletView` | `pinata-marketplace-wallet` | Optional: leave it out for renters who are not on Piñata yet |
| `PinataMarketplacePreviewView` | `pinata-marketplace-preview` | Optional: leave it out for renters who are not on Piñata yet |
| `PinataFullShoppingView` | `pinata-marketplace-full-shopping` | Required: without it the view stays empty |

Wallet and Preview run in event mode: a tap that would open the marketplace reaches your app as
a `MarketplaceOpenEvent` instead of navigating. Your app then opens Full Shopping, the complete
marketplace.

## Usage

Show the Wallet (the Preview works the same way), and open Full Shopping on the clicked item when
the event carries one:

```swift
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
```

When `authenticated` is `false`, the renter has no Piñata account yet: create it through your
backend integration (see the Partner API reference) and onboard them, then pass their `userToken`.

In SwiftUI, wrap the view in a `UIViewRepresentable`:

```swift
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
```

## Events

`MarketplaceOpenEvent` has `source`, `authenticated`, `detailsId`, `detailsType` and `entryPoint`.

| Tap | `source` | `detailsId` / `detailsType` | `entryPoint` |
| --- | --- | --- | --- |
| Wallet main button | `wallet` | none | none |
| Preview card | `preview` | the item; `detailsType` is `deal`, `reward` or `giveaway` | none |
| Preview "View all" | `preview` | none | `featured` or `browse_marketplace` |
| "Claim your prize" banner (Wallet or Preview, after the renter wins a giveaway) | `wallet` or `preview` | the giveaway, `giveaway` | `winner_banner` |

Pass `detailsId` and `detailsType` to `PinataFullShoppingView` as they are. Other callbacks:

| Callback | Called when |
| --- | --- |
| `onDetailsConsumed` (Full Shopping) | The item passed in `detailsId` was opened, or the renter declined the consent screen that comes before it |
| `onError` | The component reports an error while loading (for example an invalid or expired `userToken`), or `load()` is called on a destroyed view |
| `onMessage` | Every message the component posts, as a raw JSON string, also the ones that have a typed callback |

All callbacks run on the main thread.

## Customization

Each view has a typed `customization` (`WalletCustomization`, `PreviewCustomization`,
`FullShoppingCustomization`) whose fields map to the web component's `customization` keys. Only
the fields you set are sent; the component applies its defaults to the rest.

```swift
wallet.customization.ctaText = "Browse marketplace"
wallet.customization.colorScheme.primaryColor = "#0055FF"
```

Keys the SDK does not type yet go in `extraCustomization` (a `[String: Any]`). Typed fields win.

## Good to know

- **Environments:** `.production` (default) and `.sandbox` for testing. Use tokens from the same
  environment.
- **Size:** the component fills the view. Give the view a frame or constraints, as with any
  `UIView`.
- **Properties are read by `load()`.** To change them later, set them and call `load()` again.
- **Single use:** when the view is removed from its superview it destroys its `WKWebView`. To
  show the component again, create a new instance. A screen pushed on top of it does not remove
  it: going back shows the component as it was.
- **Links:** pages that leave the marketplace, such as a deal on the merchant's site, open in an
  in-app Safari view (`SFSafariViewController`).
- **Debugging:** in Debug builds the web view is inspectable from Safari on the Mac
  (Develop > your device or simulator), on iOS 16.4 or later.

## Development

Requirements: Xcode 16 or newer. The package has no dependencies.

```bash
xcodebuild test -scheme PinataUI -destination 'platform=iOS Simulator,name=iPhone 16' CODE_SIGNING_ALLOWED=NO
```

The demo app (`Example/`, SwiftUI, V2 flow: Wallet and Preview open Full Shopping on the
clicked item) is generated with [XcodeGen](https://github.com/yonaskolb/XcodeGen):

```bash
brew install xcodegen
xcodegen generate --spec Example/project.yml
open Example/PinataUIExample.xcodeproj
```

Pick a simulator and run. Token and environment come from the scheme's environment variables
(Edit Scheme > Run > Arguments): `PINATA_DEMO_TOKEN` (empty runs anonymous, Full Shopping won't
open) and `PINATA_DEMO_ENV` (`production`, `sandbox` or `dev`).

Releases are tags `v<version>` on `main`; Swift Package Manager resolves them directly. The Swift
code blocks in this README are compiled by the test suite (`ReadmeSnippets.swift`), so keep both
in sync.

## License

MIT
