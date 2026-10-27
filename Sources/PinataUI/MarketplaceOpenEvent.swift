import Foundation

/// The `pinata-marketplace-open` event: the renter asked to open the marketplace.
/// `detailsId`/`detailsType` (and `entryPoint`) are present when a specific item was clicked;
/// pass them to `PinataFullShoppingView` to land on that item.
public struct MarketplaceOpenEvent: Equatable {
  public let source: String
  public let authenticated: Bool
  public let detailsId: String?
  public let detailsType: String?
  public let entryPoint: String?

  public init(source: String, authenticated: Bool, detailsId: String? = nil, detailsType: String? = nil, entryPoint: String? = nil) {
    self.source = source
    self.authenticated = authenticated
    self.detailsId = detailsId
    self.detailsType = detailsType
    self.entryPoint = entryPoint
  }

  static func fromJSON(_ json: [String: Any]) -> MarketplaceOpenEvent {
    MarketplaceOpenEvent(
      source: json["source"] as? String ?? "",
      authenticated: json["authenticated"] as? Bool ?? false,
      detailsId: nonEmpty(json["detailsId"]),
      detailsType: nonEmpty(json["detailsType"]),
      entryPoint: nonEmpty(json["entryPoint"])
    )
  }

  private static func nonEmpty(_ value: Any?) -> String? {
    guard let string = value as? String, !string.isEmpty else { return nil }
    return string
  }
}
