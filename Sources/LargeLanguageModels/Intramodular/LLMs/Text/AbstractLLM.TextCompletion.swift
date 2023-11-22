//
// Copyright (c) Vatsal Manot
//

import Compute
import Foundation
import Swallow

extension AbstractLLM {
    public struct TextCompletion: Completion {
        public static var _completionType: AbstractLLM.CompletionType? {
            .text
        }
        
        public let prefix: PromptLiteral
        public let text: String
        
        public init(
            prefix: PromptLiteral,
            text: String
        ) {
            self.prefix = prefix
            self.text = text
        }
        
        public var description: String {
            text.description
        }
    }
}

// MARK: - Conformances

extension AbstractLLM.TextCompletion: Partializable {
    public typealias Partial = Self
    
    public mutating func coalesceInPlace(
        with partial: Partial
    ) throws {
        fatalError(.unexpected)
    }
    
    public static func coalesce(
        _ partials: some Sequence<Partial>
    ) throws -> Self {
        fatalError(.unexpected)
    }
}
