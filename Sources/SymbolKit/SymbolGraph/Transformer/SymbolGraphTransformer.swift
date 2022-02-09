/*
 This source file is part of the Swift.org open source project

 Copyright (c) 2022 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception

 See https://swift.org/LICENSE.txt for license information
 See https://swift.org/CONTRIBUTORS.txt for Swift project authors
*/

/// A utility type that transforms a symbol graph file.
public protocol SymbolGraphTransformer {
    /// Transforms the given symbols.
    ///
    /// To transform a symbol graph value, use ``transform(symbolGraph:)``.
    func transformSymbols(_ symbols: [String: SymbolGraph.Symbol]) -> [String: SymbolGraph.Symbol]
}

public extension SymbolGraphTransformer {
    /// Transforms a symbol graph's symbols and relationships.
    ///
    /// This method transforms the symbol graph's symbols and updates its relationships to only keep symbols that still exist.
    ///
    /// - Parameter symbolGraph: The symbol graph to transform.
    /// - Returns: The transformed symbol graph with updated symbols and relationships.
    func transform(symbolGraph: SymbolGraph) -> SymbolGraph {
        let symbols = transformSymbols(symbolGraph.symbols)
        
        var symbolGraph = symbolGraph
        symbolGraph.symbols = symbols
        
        let symbolsPreciseIdentifiers = symbols.map(\.key)
        
        symbolGraph.relationships = symbolGraph.relationships.filter { relationship in
            symbolsPreciseIdentifiers.contains(relationship.source)
                && symbolsPreciseIdentifiers.contains(relationship.target)
        }
        
        return symbolGraph
    }
}
