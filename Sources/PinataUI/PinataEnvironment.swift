import Foundation

/// Pinata environment the component runs against. `dev` is internal to Pinata.
public enum PinataEnvironment: String, CaseIterable {
  case production
  case sandbox
  case dev

  public var scriptURL: URL {
    switch self {
    case .production: return URL(string: "https://static.pinata.ai/static/ui/pinata-ui.latest.js")!
    case .sandbox: return URL(string: "https://static.pinata.ai/static/ui/pinata-ui.latest-sandbox.js")!
    case .dev: return URL(string: "https://static.pinata.ai/static/ui/pinata-ui.latest-alpha-dev.js")!
    }
  }

  public var baseURL: URL {
    switch self {
    case .production: return URL(string: "https://pinata.ai")!
    case .sandbox: return URL(string: "https://sandbox.pinata.ai")!
    case .dev: return URL(string: "https://dev.pinata.ai")!
    }
  }

  /// Value of the component's `environment` attribute; nil when the bundle's default applies.
  var elementEnvironment: String? {
    self == .dev ? "dev" : nil
  }
}
