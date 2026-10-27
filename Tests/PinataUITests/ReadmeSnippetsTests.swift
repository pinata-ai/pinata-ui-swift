import XCTest

final class ReadmeSnippetsTests: XCTestCase {

  /// Every Swift block of the README must be in ReadmeSnippets.swift verbatim, so compiling the
  /// test target proves the guide compiles. Manifest fragments (`// Package.swift`) are skipped.
  func testEveryReadmeSwiftBlockIsCompiled() throws {
    let tests = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
    let readme = try String(contentsOf: tests.appendingPathComponent("../../README.md"), encoding: .utf8)
    let snippets = try String(contentsOf: tests.appendingPathComponent("ReadmeSnippets.swift"), encoding: .utf8)

    let blocks = readme.components(separatedBy: "```swift\n").dropFirst()
      .compactMap { $0.components(separatedBy: "\n```").first }
      .filter { !$0.hasPrefix("// Package.swift") }

    XCTAssertEqual(blocks.count, 3)
    for block in blocks {
      XCTAssertTrue(snippets.contains(block), "README block missing from ReadmeSnippets.swift:\n\(block)")
    }
  }
}
