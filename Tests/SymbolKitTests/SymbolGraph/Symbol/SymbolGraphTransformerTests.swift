/*
 This source file is part of the Swift.org open source project

 Copyright (c) 2022 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception

 See https://swift.org/LICENSE.txt for license information
 See https://swift.org/CONTRIBUTORS.txt for Swift project authors
*/

import XCTest
import Foundation
@testable import SymbolKit

class SymbolGraphTransformerTests: XCTestCase {
    func testUpdatesRelationshipsWithSymbolsThatStillExist() throws {
        func symbol(withName name: String) -> String {
            """
            {
              "kind": {
                "identifier": "swift.func",
                "displayName": "Function"
              },
              "identifier": {
                "precise": "\(name)",
                "interfaceLanguage": "swift"
              },
              "pathComponents": [],
              "names": {
                "title": "\(name)"
              },
              "accessLevel": "public"
            }
            """
        }
        
        let symbolGraphData = Data(
            """
            {
              "metadata" : {
                "generator" : "unit-test",
                "formatVersion" : {
                  "major" : 1,
                  "minor" : 0,
                  "patch" : 0
                }
              },
              "relationships" : [
                {
                  "kind": "memberOf",
                  "source": "a",
                  "target": "b"
                },
                {
                  "kind": "memberOf",
                  "source": "b",
                  "target": "c"
                },
                {
                  "kind": "memberOf",
                  "source": "c",
                  "target": "a"
                },
                {
                  "kind": "memberOf",
                  "source": "b",
                  "target": "a"
                }
              ],
              "symbols" : [
                \(symbol(withName: "a")),
                \(symbol(withName: "b")),
                \(symbol(withName: "c")),
              ],
              "module" : {
                "name" : "ModuleName",
                "platform" : {}
              }
            }
            """.utf8
        )
        
        let symbolGraph = try JSONDecoder().decode(SymbolGraph.self, from: symbolGraphData)
        
        let newSymbolGraph = TestSymbolGraphTransformer().transform(symbolGraph: symbolGraph)
        
        XCTAssertEqual(newSymbolGraph.symbols.map(\.key).sorted(), ["a", "b"])
        
        XCTAssertEqual(
            newSymbolGraph.relationships.map { "\($0.source) -> \($0.target)" }.sorted(),
            [
                "a -> b",
                "b -> a",
            ],
            "Unexpected relationships. Expected relationships that don't include 'a' or 'b' to have been removed."
        )
    }
}

private struct TestSymbolGraphTransformer: SymbolGraphTransformer {
    func transformSymbols(_ symbols: [String : SymbolGraph.Symbol]) -> [String : SymbolGraph.Symbol] {
        symbols.filter { ["a", "b"].contains($0.key) }
    }
}
