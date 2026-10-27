import Foundation

/// Typed `customization` for each component, mirroring the web contract and the Kotlin SDK.
/// Every field is optional: only what you set is sent, and the web component applies its own
/// defaults to the rest.

/// How values are shown and reported. Some companies have an allowed list on Pinata's side.
public enum PinataCurrency: String {
  case pinata
  case points
  case dollar
}

/// Hex colors like "#RRGGBB". Each component reads the keys it supports.
public struct ColorScheme {
  public var primaryColor: String?
  public var secondaryColor: String?
  public var white: String?
  public var dark: String?
  /// Wallet only: the points balance and icon. It does not follow `primaryColor`; set both.
  public var walletColor: String?
  /// Preview and Full Shopping only.
  public var fontColor: String?

  public init() {}

  func toJSON() -> [String: Any]? {
    json([
      "primaryColor": primaryColor,
      "secondaryColor": secondaryColor,
      "white": white,
      "dark": dark,
      "walletColor": walletColor,
      "fontColor": fontColor,
    ])
  }
}

/// Renter attributes for offer targeting.
public struct RenterAttributes {
  public var zipCode: String?
  public var leaseStartDate: String?
  public var leaseEndDate: String?
  public var rentAmount: String?
  public var gender: String?
  public var loyaltyLevel: String?

  public init() {}

  func toJSON() -> [String: Any]? {
    json([
      "zipCode": zipCode,
      "leaseStartDate": leaseStartDate,
      "leaseEndDate": leaseEndDate,
      "rentAmount": rentAmount,
      "gender": gender,
      "loyaltyLevel": loyaltyLevel,
    ])
  }
}

public struct SectionLabels {
  public var title: String?
  public var viewAllCta: String?

  public init() {}

  func toJSON() -> [String: Any]? { json(["title": title, "viewAllCta": viewAllCta]) }
}

public struct WalletCustomization {
  public var widgetTitle: String?
  public var ctaText: String?
  public var disabledCta: Bool?
  public var helperText: String?
  /// Text link under the header; both are needed for it to show.
  public var descriptionCopy: String?
  public var descriptionUrl: String?
  public var companyName: String?
  public var currentPageUrl: String?
  public var colorScheme = ColorScheme()

  public init() {}

  func toJSON() -> [String: Any]? {
    json([
      "widgetTitle": widgetTitle,
      "ctaText": ctaText,
      "disabledCta": disabledCta,
      "helperText": helperText,
      "description": json(["copy": descriptionCopy, "url": descriptionUrl]),
      "companyName": companyName,
      "currentPageUrl": currentPageUrl,
      "colorScheme": colorScheme.toJSON(),
    ])
  }
}

public struct PreviewLabels {
  public var featured = SectionLabels()
  public var browseMarketplace = SectionLabels()

  public init() {}

  func toJSON() -> [String: Any]? {
    json(["featured": featured.toJSON(), "browseMarketplace": browseMarketplace.toJSON()])
  }
}

public struct PreviewCustomization {
  public var labels = PreviewLabels()
  public var currency: PinataCurrency?
  public var companyName: String?
  public var companyCustomizationKey: String?
  public var currentPageUrl: String?
  public var useCustomFont: Bool?
  public var attributes = RenterAttributes()
  public var colorScheme = ColorScheme()

  public init() {}

  func toJSON() -> [String: Any]? {
    json([
      "labels": labels.toJSON(),
      "currency": currency?.rawValue,
      "companyName": companyName,
      "companyCustomizationKey": companyCustomizationKey,
      "currentPageUrl": currentPageUrl,
      "useCustomFont": useCustomFont,
      "attributes": attributes.toJSON(),
      "colorScheme": colorScheme.toJSON(),
    ])
  }
}

public struct BrowseMarketplaceLabels {
  public var title: String?
  public var searchPlaceholder: String?

  public init() {}

  func toJSON() -> [String: Any]? { json(["title": title, "searchPlaceholder": searchPlaceholder]) }
}

public struct WalletCardLabels {
  public var accessAccountCta: String?

  public init() {}

  func toJSON() -> [String: Any]? { json(["accessAccountCta": accessAccountCta]) }
}

public struct FullShoppingLabels {
  public var featured = SectionLabels()
  public var winThisMonth = SectionLabels()
  public var lastChance = SectionLabels()
  public var browseMarketplace = BrowseMarketplaceLabels()
  public var walletCard = WalletCardLabels()

  public init() {}

  func toJSON() -> [String: Any]? {
    json([
      "featured": featured.toJSON(),
      "winThisMonth": winThisMonth.toJSON(),
      "lastChance": lastChance.toJSON(),
      "browseMarketplace": browseMarketplace.toJSON(),
      "walletCard": walletCard.toJSON(),
    ])
  }
}

/// Colors of an item's details view. These live at the root of `customization` on the web.
public struct DetailsColors {
  public var detailsCtaContainerColor: String?
  public var detailsCtaContainerFontColor: String?
  public var detailsPointsBadgeColor: String?
  public var detailsPointsBadgeFontColor: String?
  public var detailsTagFontColor: String?
  public var detailsTextFontColor: String?
  public var detailsActionColor: String?
  public var detailsActionFontColor: String?

  public init() {}

  func toJSON() -> [String: Any]? {
    json([
      "detailsCtaContainerColor": detailsCtaContainerColor,
      "detailsCtaContainerFontColor": detailsCtaContainerFontColor,
      "detailsPointsBadgeColor": detailsPointsBadgeColor,
      "detailsPointsBadgeFontColor": detailsPointsBadgeFontColor,
      "detailsTagFontColor": detailsTagFontColor,
      "detailsTextFontColor": detailsTextFontColor,
      "detailsActionColor": detailsActionColor,
      "detailsActionFontColor": detailsActionFontColor,
    ])
  }
}

public struct FullShoppingCustomization {
  public var widgetTitle: String?
  public var widgetDescription: String?
  public var companyName: String?
  public var companyCustomizationKey: String?
  public var currency: PinataCurrency?
  public var currentPageUrl: String?
  public var useCustomFont: Bool?
  public var walletSectionEnabled: Bool?
  public var transactionHistoryEnabled: Bool?
  public var attributes = RenterAttributes()
  public var labels = FullShoppingLabels()
  public var colorScheme = ColorScheme()
  public var detailsColors = DetailsColors()

  public init() {}

  /// Never nil: Full Shopping always sends an object, as the Kotlin SDK does.
  func toJSON() -> [String: Any] {
    var object = json([
      "widgetTitle": widgetTitle,
      "widgetDescription": widgetDescription,
      "companyName": companyName,
      "companyCustomizationKey": companyCustomizationKey,
      "currency": currency?.rawValue,
      "currentPageUrl": currentPageUrl,
      "useCustomFont": useCustomFont,
      "walletSectionEnabled": walletSectionEnabled,
      "transactionHistoryEnabled": transactionHistoryEnabled,
      "attributes": attributes.toJSON(),
      "labels": labels.toJSON(),
      "colorScheme": colorScheme.toJSON(),
    ]) ?? [:]
    detailsColors.toJSON()?.forEach { object[$0.key] = $0.value }
    return object
  }
}

/// Builds a dictionary with the non-nil pairs only; nil when nothing was set.
/// Nested empty objects (nil) are dropped too.
func json(_ pairs: [String: Any?]) -> [String: Any]? {
  var object: [String: Any] = [:]
  for (key, value) in pairs {
    guard let value else { continue }
    object[key] = value
  }
  return object.isEmpty ? nil : object
}
