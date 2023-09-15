//
// Copyright (c) Vatsal Manot
//

import Diagnostics
import Foundation
import Swallow

extension AbstractLLM {
    public struct ChatMessage: Codable, Hashable, Sendable {
        public let role: ChatRole
        public let content: PromptLiteral
        
        public init(role: ChatRole, content: PromptLiteral) {
            _expectNoThrow {
                if let functionCallOrInvocation = try content._degenerate()._getFunctionCallOrInvocation() {
                    if functionCallOrInvocation is AbstractLLM.ChatPrompt.FunctionCall {
                        assert(role == .assistant)
                    } else if functionCallOrInvocation is AbstractLLM.ChatPrompt.FunctionInvocation {
                        assert(role == .other(.function))
                    }
                }
            }
            
            self.role = role
            self.content = content
        }
        
        public init(role: ChatRole, content: String) {
            self.init(role: role, content: PromptLiteral(stringLiteral: content))
        }
    }
}

// MARK: - Extensions

extension AbstractLLM.ChatMessage {
    public mutating func _unsafelyAppend(other message: Self) {
        assert(role == message.role)
        
        self = Self(
            role: role,
            content: PromptLiteral.concatenate(separator: nil, [content, message.content])
        )
    }
}

// MARK: - Conformances

extension AbstractLLM.ChatMessage: CustomDebugStringConvertible {
    public var debugDescription: String {
        "\(role): \(content)"
    }
}

// MARK: - Initializers

extension AbstractLLM.ChatMessage {
    public static func assistant(
        _ content: PromptLiteral
    ) -> Self {
        Self(role: .assistant, content: content)
    }
    
    public static func assistant(
        _ content: () -> PromptLiteral
    ) -> Self {
        Self(role: .assistant, content: content())
    }
    
    public static func assistant(
        _ content: String
    ) -> Self {
        Self(role: .assistant, content: content)
    }
    
    public static func assistant(
        _ content: () -> String
    ) -> Self {
        Self(role: .assistant, content: content())
    }
}

extension AbstractLLM.ChatMessage {
    public static func system(
        _ content: PromptLiteral
    ) -> Self {
        Self(role: .system, content: content)
    }
    
    public static func system(
        _ content: () -> PromptLiteral
    ) -> Self {
        Self(role: .system, content: content())
    }
    
    public static func system(
        _ content: String
    ) -> Self {
        Self(role: .system, content: content)
    }
    
    public static func system(
        _ content: () -> String
    ) -> Self {
        Self(role: .system, content: content())
    }
}

extension AbstractLLM.ChatMessage {
    public static func user(
        _ content: PromptLiteral
    ) -> Self {
        Self(role: .user, content: content)
    }
    
    public static func user(
        _ content: () -> PromptLiteral
    ) -> Self {
        Self(role: .user, content: content())
    }
    
    public static func user(
        _ content: String
    ) -> Self {
        Self(role: .user, content: content)
    }
    
    public static func user(
        _ content: () -> String
    ) -> Self {
        Self(role: .user, content: content())
    }
}
