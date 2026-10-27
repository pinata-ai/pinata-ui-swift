# pinata-ui-swift

iOS SDK for the Piñata marketplace components, the Swift twin of
[pinata-ui-kotlin](https://github.com/pinata-ai/pinata-ui-kotlin): one `UIView` per component
(`PinataMarketplaceWalletView`, `PinataMarketplacePreviewView`, `PinataFullShoppingView`)
wrapping the Piñata web component in a `WKWebView`, with event mode on by default, typed
callbacks for `pinata-marketplace-open`, and `SFSafariViewController` for pages that leave the
marketplace.

The integration guide is coming with the first release. Until then the Kotlin README describes
the same API.

## Development

Requirements: Xcode 16 or newer. The package has no dependencies.

```bash
xcodebuild build -scheme PinataUI -destination 'generic/platform=iOS Simulator'
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
open) and `PINATA_DEMO_ENV` (`production`, `sandbox` or `dev`). Debug builds are inspectable from
Safari (Develop > Simulator).

## License

MIT
