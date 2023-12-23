//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import Diagnostics
import Foundation
import Swallow

public protocol __AbstractLLM_ChatMessageConvertible {
    func __conversion() throws -> AbstractLLM.ChatMessage
}

extension AbstractLLM {
    public typealias ChatMessageConvertible = __AbstractLLM_ChatMessageConvertible
    
    public struct ChatMessage: Codable, Hashable, Identifiable, Sendable {
        public var id: AnyPersistentIdentifier?
        public var role: ChatRole
        public var content: PromptLiteral

        public init(
            id: AnyPersistentIdentifier? = nil,
            role: ChatRole,
            content: PromptLiteral
        ) {
            _expectNoThrow {
                if let functionCallOrInvocation = try content._degenerate()._getFunctionCallOrInvocation() {
                    if functionCallOrInvocation is AbstractLLM.ChatPrompt.FunctionCall {
                        assert(role == .assistant)
                    } else if functionCallOrInvocation is AbstractLLM.ChatPrompt.FunctionInvocation {
                        assert(role == .other(.function))
                    }
                }
            }
            
            self.id = id
            self.role = role
            self.content = content
        }
    }
}

// MARK: - Extensions

extension AbstractLLM.ChatMessage {
    public mutating func _unsafelyAppend(
        other message: Self
    ) {
        assert(role == message.role)
        
        self = Self(
            role: role,
            content: PromptLiteral.concatenate(separator: nil, [content, message.content])
        )
    }
}

// MARK: - Conformances

extension AbstractLLM.ChatMessage: AbstractLLM.ChatMessageConvertible {
    public func __conversion() throws -> AbstractLLM.ChatMessage {
        self
    }
}

extension AbstractLLM.ChatMessage: CustomDebugStringConvertible {
    public var debugDescription: String {
        "[\(role)]: \(content.delimited(by: .quotationMark))"
    }
}

// MARK: - Initializers

extension AbstractLLM.ChatMessage {
    public init(
        id: AnyPersistentIdentifier? = nil,
        role: AbstractLLM.ChatRole,
        content: String
    ) {
        self.init(
            id: id,
            role: role,
            content: PromptLiteral(stringLiteral: content)
        )
    }
    
    public init(
        id: UUID,
        role: AbstractLLM.ChatRole,
        content: String
    ) {
        self.init(
            id: AnyPersistentIdentifier(erasing: id),
            role: role,
            content: content
        )
    }
    
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
