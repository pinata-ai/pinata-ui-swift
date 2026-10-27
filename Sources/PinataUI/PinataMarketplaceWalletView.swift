import UIKit

/// Marketplace Wallet in event mode: points balance, offers and a CTA. Every CTA click
/// (and the giveaway claim banner) reaches `onMarketplaceOpen`; the view never navigates
/// on its own.
public final class PinataMarketplaceWalletView: PinataComponentView {

  override var componentTag: String { "pinata-marketplace-wallet" }
}
