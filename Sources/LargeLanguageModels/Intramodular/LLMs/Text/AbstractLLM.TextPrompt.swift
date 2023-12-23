//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

extension AbstractLLM {
    public struct TextPrompt: AbstractLLM.Prompt, Hashable, Sendable {
        public typealias CompletionParameters = AbstractLLM.TextCompletionParameters
        public typealias Completion = AbstractLLM.TextCompletion
        
        public static var completionType: AbstractLLM.CompletionType? {
            .text
        }
        
        @_HashableExistential
        public var prefix: any PromptLiteralConvertible
        public var context: PromptContextValues
        
        public init(
            prefix: any PromptLiteralConvertible,
            context: PromptContextValues = .init()
        ) {
            self.prefix = prefix
            self.context = context
        }
    }
}

// MARK: - Conformances

extension AbstractLLM.TextPrompt: CustomDebugStringConvertible {
    public var debugDescription: String {
        PromptLiteral(_lazy: prefix).debugDescription
    }
}

extension AbstractLLM.TextPrompt: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(prefix: PromptLiteral(stringLiteral: value))
    }
}
