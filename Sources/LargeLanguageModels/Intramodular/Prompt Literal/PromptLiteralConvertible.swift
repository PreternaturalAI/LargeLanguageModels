//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

public protocol _PromptLiteralConvertible {
    func _toPromptLiteral() throws -> PromptLiteral
}

public protocol PromptLiteralConvertible: _PromptLiteralConvertible, Sendable {
    @PromptLiteralBuilder
    var promptLiteral: PromptLiteral { get throws }
}

extension PromptLiteralConvertible {
    public func _toPromptLiteral() throws -> PromptLiteral {
        try promptLiteral
    }
}

// MARK: - Implemented Conformances

extension String: _PromptLiteralConvertible {
    public func _toPromptLiteral() throws -> PromptLiteral {
        .init(stringLiteral: self)
    }
}

extension PromptLiteral: PromptLiteralConvertible {
    public var promptLiteral: PromptLiteral {
        self
    }
}

// MARK: - Auxiliary

@resultBuilder
public struct PromptLiteralBuilder {
    public typealias Element = PromptLiteral
    
    public static func buildBlock() -> PromptLiteral {
        .empty
    }
    
    public static func buildBlock(
        _ element: Element
    ) -> Element {
        element
    }
    
    public static func buildEither(first: Element) -> Element {
        first
    }
    
    public static func buildEither(second: Element) -> Element {
        second
    }
    
    public static func buildOptional(
        _ component: Element?
    ) -> Element {
        component ?? .empty
    }
    
    public static func buildPartialBlock(
        first: Element
    ) -> Element {
        first
    }
    
    public static func buildPartialBlock(
        accumulated: Element,
        next: Element
    ) -> Element {
        PromptLiteral.concatenate(separator: "\n") {
            accumulated
            next
        }
    }
}

public struct AnyPromptLiteralConvertible: _MaybeAsyncProtocol, PromptLiteralConvertible {
    public var _promptLiteralAsync: (@Sendable () async throws -> PromptLiteral)?
    public var _promptLiteralNonAsync: @Sendable () throws -> PromptLiteral
    
    public var promptLiteral: PromptLiteral {
        get throws {
            try _promptLiteralNonAsync()
        }
    }
    
    public func _resolveToNonAsync() async throws -> Self {
        if let nonAsyncResolution = try? _promptLiteralNonAsync() {
            return Self {
                nonAsyncResolution
            }
        }
        
        guard let resolve = _promptLiteralAsync else {
            return self
        }
        
        let resolved = try await resolve()
        
        return Self({ resolved })
    }
    
    public init(_ promptLiteral: @escaping @Sendable () throws -> PromptLiteral) {
        self._promptLiteralAsync = nil
        self._promptLiteralNonAsync = promptLiteral
    }
    
    public init(
        _ asyncLiteral: @escaping @Sendable () async throws -> PromptLiteral,
        nonasync nonasyncLiteral: @escaping @Sendable () throws -> PromptLiteral?
    ) {
        self._promptLiteralAsync = asyncLiteral
        self._promptLiteralNonAsync = {
            if let result = try nonasyncLiteral() {
                return result
            } else {
                throw _MaybeAsyncProtocolError.needsResolving
            }
        }
    }
}
