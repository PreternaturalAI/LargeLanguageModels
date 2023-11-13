//
// Copyright (c) Vatsal Manot
//

import Compute
import Foundation
import Swallow

public protocol __AbstractLLM_Prompt: Hashable, Sendable {
    associatedtype CompletionParameters: __AbstractLLM_CompletionParameters
    associatedtype Completion: Partializable
    
    static var completionType: AbstractLLM.CompletionType? { get }
}

extension AbstractLLM {
    public enum CompletionType: CaseIterable, Hashable, Sendable {
        case text
        case chat
    }
    
    public typealias Prompt = __AbstractLLM_Prompt
}

extension AbstractLLM {
    public enum ChatOrTextPrompt: Prompt {
        public typealias CompletionParameters = AbstractLLM.ChatOrTextCompletionParameters
        public typealias Completion = AbstractLLM.ChatOrTextCompletion

        case text(TextPrompt)
        case chat(ChatPrompt)
        
        public static var completionType: AbstractLLM.CompletionType? {
            nil
        }
    }
}

// MARK: - Extensions

extension AbstractLLM.ChatOrTextPrompt {
    public var completionType: AbstractLLM.CompletionType {
        switch self {
            case .text:
                return .text
            case .chat:
                return .chat
        }
    }
    
    public static func chat(
        _ messages: () -> [AbstractLLM.ChatMessage]
    ) -> Self {
        .chat(.init(messages: messages()))
    }
    
    public static func text(_ literal: any PromptLiteralConvertible) -> Self {
        .text(.init(prefix: literal))
    }
    
    public func appending(
        _ text: String
    ) throws -> AbstractLLM.ChatOrTextPrompt {
        switch self {
            case .text(let value):
                return .text(.init(prefix: PromptLiteral(_lazy: value.prefix) + PromptLiteral(stringLiteral: text)))
            case .chat(let value):
                return .chat(value.appending(.user(text)))
        }
    }
}

// MARK: - Conformances

extension AbstractLLM.ChatOrTextCompletion: Partializable {
    public enum Partial {
        case text(AbstractLLM.TextCompletion.Partial)
        case chat(AbstractLLM.ChatCompletion.Partial)
    }
    
    public mutating func coalesceInPlace(
        with partial: Partial
    ) throws {
        switch (self, partial) {
            case (.text(var lhs), .text(let rhs)):
                try lhs.coalesceInPlace(with: rhs)
                
                self = .text(lhs)
            case (.chat(var lhs), .chat(let rhs)):
                try lhs.coalesceInPlace(with: rhs)
                
                self = .chat(lhs)
            default:
                assertionFailure()
                
                break
        }
    }
    
    public static func coalesce(
        _ partials: some Sequence<Partial>
    ) throws -> Self {
        fatalError()
    }
}

extension AbstractLLM.ChatOrTextPrompt: _UnwrappableTypeEraser {
    public typealias _UnwrappedBaseType = any AbstractLLM.Prompt
    
    public init(_erasing prompt: _UnwrappedBaseType) {
        assert(!(prompt is Self))
        
        switch prompt {
            case let prompt as AbstractLLM.TextPrompt:
                self = .text(prompt)
            case let prompt as AbstractLLM.ChatPrompt:
                self = .chat(prompt)
            default:
                fatalError(reason: .unexpected)
        }
    }
    
    public func _unwrapBase() -> _UnwrappedBaseType {
        switch self {
            case .text(let prompt):
                return prompt
            case .chat(let prompt):
                return prompt
        }
    }
}
