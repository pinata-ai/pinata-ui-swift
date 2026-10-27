import Foundation

/// Pure builders behind `PinataComponentView`, kept free of WebKit so they run in unit tests.
/// They mirror `buildCustomizationJson`, `buildElementAttributes`, `buildHostPage` and
/// `escapeAttribute` of pinata-ui-kotlin.
enum HostPage {

  /// Merges the escape hatch, the typed customization (which wins), the event mode flag and the
  /// `companyName` property (only when the customization misses it).
  static func buildCustomization(
    extra: [String: Any],
    component: [String: Any]?,
    eventMode: Bool,
    companyName: String?
  ) -> [String: Any] {
    var json = extra
    component?.forEach { json[$0.key] = $0.value }
    if eventMode { json["navigationMode"] = "events" }
    if let companyName, json["companyName"] == nil { json["companyName"] = companyName }
    return json
  }

  static func buildElementAttributes(
    environment: PinataEnvironment,
    userToken: String?,
    customization: [String: Any]
  ) -> String {
    var attributes = ""
    if let element = environment.elementEnvironment { attributes += " environment=\"\(element)\"" }
    if let userToken { attributes += " usertoken=\"\(escapeAttribute(userToken))\"" }
    attributes += " customization='\(escapeAttribute(serialize(customization)))'"
    return attributes
  }

  static func buildHostPage(scriptURL: URL, componentTag: String, elementAttributes: String) -> String {
    """
    <!doctype html>
    <html>
    <head>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>html, body { margin: 0; height: 100%; }</style>
    <script type="module" src="\(scriptURL.absoluteString)"></script>
    <script>
      addEventListener("message", e => webkit.messageHandlers.PinataBridge.postMessage(JSON.stringify(e.data)));
      addEventListener("DOMContentLoaded", () =>
        document.body.firstElementChild.addEventListener("pinata-error", e =>
          webkit.messageHandlers.PinataBridge.postMessage(JSON.stringify({type: "pinata-error", detail: e.detail == null ? "" : e.detail}))));
    </script>
    </head>
    <body>
    <\(componentTag) style="display:block;height:100vh"\(elementAttributes)></\(componentTag)>
    </body>
    </html>
    """
  }

  static func escapeAttribute(_ value: String) -> String {
    value
      .replacingOccurrences(of: "&", with: "&amp;")
      .replacingOccurrences(of: "'", with: "&#39;")
      .replacingOccurrences(of: "\"", with: "&quot;")
  }

  /// Compact JSON with sorted keys, so the output is stable across runs.
  static func serialize(_ json: Any) -> String {
    guard JSONSerialization.isValidJSONObject(json),
      let data = try? JSONSerialization.data(withJSONObject: json, options: [.sortedKeys]),
      let string = String(data: data, encoding: .utf8)
    else { return "{}" }
    return string
  }
}
