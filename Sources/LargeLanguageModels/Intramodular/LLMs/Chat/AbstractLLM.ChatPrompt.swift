//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

extension AbstractLLM {
    public struct ChatPrompt: AbstractLLM.Prompt, Hashable, Sendable {
        public typealias CompletionParameters = AbstractLLM.ChatCompletionParameters
        public typealias Completion = AbstractLLM.ChatCompletion
        
        public struct FunctionCall: Codable, CustomDebugStringConvertible, Hashable, Sendable {
            public let name: String
            public let arguments: String
            
            public var debugDescription: String {
                "<function call: \(name)>"
            }
            
            public init(name: String, arguments: String) {
                self.name = name
                self.arguments = arguments
            }
        }
        
        public static var completionType: AbstractLLM.CompletionType? {
            .chat
        }
        
        public var messages: [AbstractLLM.ChatMessage]
        public var context: PromptContextValues {
            didSet {
                if context.completionType != nil {
                    assert(context.completionType == .chat)
                } else {
                    context.completionType = .chat
                }
            }
        }
        
        public init(
            messages: [AbstractLLM.ChatMessage],
            context: PromptContextValues
        ) {
            self.messages = messages
            self.context = context
            
            if context.completionType != nil {
                assert(context.completionType == .chat)
            }
        }
    }
}

extension AbstractLLM.ChatPrompt {
    public var _rawContent: PromptLiteral {
        get throws {
            // FIXME!!!
            // This currently discards role and possibly other metadata
            
            return PromptLiteral.concatenate(separator: nil) {
                messages.map({ $0.content })
            }
        }
    }
}

extension AbstractLLM.ChatPrompt {
    public mutating func append(
        _ message: AbstractLLM.ChatMessage
    ) {
        messages.append(message)
    }
    
    public func appending(
        _ message: AbstractLLM.ChatMessage
    ) -> Self {
        withMutableScope(self) {
            $0.append(message)
        }
    }
}

// MARK: - Conformances

extension AbstractLLM.ChatPrompt: CustomDebugStringConvertible {
    public var debugDescription: String {
        messages
            .map({ $0.debugDescription })
            .joined(separator: .init(Character.newline))
    }
}

extension AbstractLLM.ChatPrompt: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: AbstractLLM.ChatMessage...) {
        self.init(messages: elements, context: PromptContextValues())
    }
}

// MARK: - Auxiliary

extension AbstractLLM.ChatPrompt {
    public struct FunctionResult: Codable, Hashable, Sendable {
        public let rawValue: String
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
    
    public struct FunctionInvocation: Codable, Hashable, Sendable {
        public let name: String
        public let result: FunctionResult
        
        public var debugDescription: String {
            "<function invocation: \(name)>"
        }
        
        public init(name: String, result: FunctionResult) {
            self.name = name
            self.result = result
        }
    }
}
