# Pinata UI iOS mock

Throwaway mock, not the SDK. A bare `WKWebView` around the [Partner UI Demo Site](https://github.com/pinata-ai/Partner-UI-Demo-Site), the iOS twin of `pinata-ui-android-mock`, so we can show the marketplace components (wallet, preview, full shopping) running inside a native iOS app and the events reaching it.

What it should prove (written on Windows, not yet run on a Mac): the web bundle renders in `WKWebView` as is; deals, account settings and "open marketplace" (which use `window.open()`) open in `SFSafariViewController`; and what the components already emit reaches the app, shown as a toast: messages posted to the top window (`pinata-embed-ready`, `pinata-preview-browse-marketplace` from the anonymous wallet CTA) and top-level redirects (`ctaUrlRedirect` from the authenticated wallet CTA). The real SDK is specified in the spike (`spike-native-webview/`).

There are only two source files, in `PinataUIMock/`. They use WebKit, SafariServices and SwiftUI, nothing else: no packages, no Pods.

## Step by step in Xcode (no extra tools)

Requirements: Xcode 15 or newer, an iOS 16+ simulator (any iPhone from the Xcode list works).

1. Open Xcode and choose **File > New > Project**.
2. Pick the **iOS** tab, then **App**, and click **Next**.
3. Fill the form exactly like this and click **Next**:
   - Product Name: `PinataUIMock`
   - Team: any (none is fine for the simulator)
   - Organization Identifier: `com.pinata`
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Storage: **None**
   - Include Tests: unchecked
4. Save the project anywhere (for example in this folder). Xcode opens it with two files it generated: `PinataUIMockApp.swift` and `ContentView.swift`.
5. In the Project navigator (left panel), select those two generated files, right-click, **Delete**, then **Move to Trash**. The project must end up with a single `@main`, which is the one in our `PinataUIMockApp.swift`.
6. Drag the two files from this repo's `PinataUIMock/` folder (`PinataUIMockApp.swift` and `DemoWebView.swift`) into the `PinataUIMock` group in the Project navigator. In the dialog, check **Copy items if needed** and make sure the `PinataUIMock` target is checked under **Add to targets**. Click **Finish**.
7. Click the project (blue icon at the top of the navigator), select the `PinataUIMock` target, tab **General**, and confirm **Minimum Deployments** is **iOS 16.0** or higher. The code needs iOS 16 (`Task.sleep(for:)`).
8. At the top bar, pick an iPhone simulator as the run destination and press **Run** (⌘R).
9. The app opens the demo page. The demo site asks for its password; after that the wallet component loads and the first toast appears.

To change the component, edit `demoURL` in `PinataUIMockApp.swift`: `component=marketplace-small` (wallet), `marketplace-large` (preview) or `fullshop`.

## Shortcut with XcodeGen (optional)

If you have [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`), the project is generated from `project.yml` and steps 1 to 7 are not needed:

```bash
xcodegen generate
open PinataUIMock.xcodeproj
```

Then pick a simulator and press Run.

## What to check

Record the screen (⌘R on the simulator starts a recording) and go through this list. Each toast stays for about 3 seconds at the bottom of the screen.

1. Wallet (anonymous) renders; a toast `Event received: "pinata-embed-ready"` shows on load.
2. Scroll to the wallet and tap **Browse marketplace**: toast `Event received: "pinata-preview-browse-marketplace"`.
3. Scroll up, switch **User Type** to **Authenticated**, scroll down and tap the CTA: toast `Redirect intercepted: https://example.com/` (the demo `ctaUrlRedirect`).
4. Clear the **CTA URL Redirect** field, wait for the wallet to reload, tap the CTA again: `SFSafariViewController` opens the Pinata web page. The dev demo users still need onboarding, so it lands on the email code screen; that is the expected V1 flow.
5. Change `demoURL` to `component=fullshop`, run again: **Get this deal** and **Access your full Pinata account** open in `SFSafariViewController`, logged in.
6. Keyboard inside the iframe forms, scroll, swipe back.

If step 4 or 5 does not open Safari, the popup from `window.open()` did not reach `createWebViewWith` in `DemoWebView.swift`. Fallback to try: make that method `return nil`; the wallet then calls `window.open(url)` directly, which hits the same method with the final URL.

Inspect the page with Safari on the Mac: **Develop > Simulator > PinataUIMock** (debug builds set `isInspectable`).
