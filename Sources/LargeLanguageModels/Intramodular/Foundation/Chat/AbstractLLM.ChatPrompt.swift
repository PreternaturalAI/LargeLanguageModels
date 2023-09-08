//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

extension AbstractLLM {
    public struct ChatPrompt: AbstractLLM.Prompt, Hashable, Sendable {
        public typealias CompletionParameters = AbstractLLM.ChatCompletionParameters
        public typealias Completion = AbstractLLM.ChatCompletion
        
        public struct FunctionCall: Codable, Hashable, Sendable {
            public let name: String
            public let arguments: String
            
            public init(name: String, arguments: String) {
                self.name = name
                self.arguments = arguments
            }
        }
                
        public static var completionType: AbstractLLM.CompletionType? {
            .chat
        }
        
        public var messages: [AbstractLLM.ChatMessage]
        
        public init(messages: [AbstractLLM.ChatMessage]) {
            self.messages = messages
        }
    }
}

extension AbstractLLM.ChatPrompt {
    public func appending(_ message: AbstractLLM.ChatMessage) -> Self {
        .init(messages: messages.appending(message))
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
        self.init(messages: elements)
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
        
        public init(name: String, result: FunctionResult) {
            self.name = name
            self.result = result
        }
    }
}
