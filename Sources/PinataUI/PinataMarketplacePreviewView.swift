import UIKit

/// Marketplace Preview in event mode: rows of offer cards. Card clicks reach
/// `onMarketplaceOpen` with the clicked item (`detailsId`/`detailsType`);
/// "View all" sends the same event without an item.
public final class PinataMarketplacePreviewView: PinataComponentView {

  override var componentTag: String { "pinata-marketplace-preview" }
}
