//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

public protocol __AbstractLLM_Completion: Codable, CustomDebugStringConvertible, Hashable, Sendable {
    static var _completionType: AbstractLLM.CompletionType? { get }
}

extension AbstractLLM {
    public typealias Completion = __AbstractLLM_Completion
}

extension AbstractLLM {
    /// Completion parameters shared between text and chat LLM inference.
    public struct ChatOrTextCompletionParameters: AbstractLLM.CompletionParameters {
        public let temperature: Double?
        public let topProbabilityMass: Double?
        public let numberOfCompletions: Int
        public let stops: [String] = []
        public let maxTokens: AbstractLLM.TokenLimit
        public let presencePenalty: Double?
        public let frequencyPenalty: Double?
    }

    public enum ChatOrTextCompletion: CustomStringConvertible, Hashable, Sendable {
        public static var _completionType: AbstractLLM.CompletionType? {
            nil
        }
        
        case text(TextCompletion)
        case chat(ChatCompletion)
        
        public var type: AbstractLLM.CompletionType {
            switch self {
                case .text:
                    return .text
                case .chat:
                    return .chat
            }
        }
        
        public var description: String {
            switch self {
                case .text(let value):
                    return String(describing: value)
                case .chat(let value):
                    return String(describing: value)
            }
        }
    }
}

// MARK: - Extensions

extension AbstractLLM.ChatOrTextCompletion {
    public var _textCompletion: AbstractLLM.TextCompletion? {
        guard case .text(let value) = self else {
            return nil
        }
        
        return value
    }
    
    public var _chatCompletion: AbstractLLM.ChatCompletion? {
        guard case .chat(let value) = self else {
            return nil
        }
        
        return value
    }
}

extension AbstractLLM.ChatOrTextCompletion {
    public func _stripToRawLiteral() throws -> PromptLiteral {
        switch self {
            case .text(let completion):
                return .init(stringLiteral: completion.text)
            case .chat(let completion):
                return completion.message.content
        }
    }
}
