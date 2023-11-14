//
// Copyright (c) Vatsal Manot
//

import Compute
import Foundation
import Swallow

extension AbstractLLM {
    public struct ChatCompletion: Completion {
        public static var _completionType: AbstractLLM.CompletionType? {
            .chat
        }

        public let message: AbstractLLM.ChatMessage
        
        public init(message: AbstractLLM.ChatMessage) {
            self.message = message
        }
        
        public var debugDescription: String {
            message.debugDescription
        }
    }
}

// MARK: - Conformances

extension AbstractLLM.ChatCompletion: Partializable {
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
