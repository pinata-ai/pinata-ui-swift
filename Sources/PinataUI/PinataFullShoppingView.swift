import UIKit

/// Full Shopping: the complete marketplace, the destination of every `MarketplaceOpenEvent`.
/// Requires `userToken`. Set `detailsId`/`detailsType` (straight from the event) to land on
/// that item instead of home.
public final class PinataFullShoppingView: PinataComponentView {

  override var componentTag: String { "pinata-marketplace-full-shopping" }
  override var usesEventMode: Bool { false }

  public var customization = FullShoppingCustomization()
  public var detailsId: String?
  public var detailsType: String?

  override func componentCustomization() -> [String: Any]? { customization.toJSON() }

  override func buildCustomization() -> [String: Any] {
    var json = super.buildCustomization()
    if let detailsId { json["detailsId"] = detailsId }
    if let detailsType { json["detailsType"] = detailsType }
    return json
  }

  override func elementAttributes() -> String {
    " useFixedHeight=\"false\"" + super.elementAttributes()
  }
}
