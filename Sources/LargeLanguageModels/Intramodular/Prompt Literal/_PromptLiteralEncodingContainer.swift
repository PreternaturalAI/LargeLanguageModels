//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

/// A type capable of encoding a `PromptLiteral` into itself.
///
/// This is a useful interface for 3rd party models to adopt to support conversion _from_ `PromptLiteral`.
public protocol _PromptLiteralEncodingContainer {
    mutating func encode(_ degenerate: PromptLiteral._Degenerate.Component) throws
}

// MARK: - Supplementary

extension PromptLiteral {
    /// Encode this literal into an encoding container.
    public func _encode<Container: _PromptLiteralEncodingContainer>(
        to container: inout Container
    ) throws {
        let degenerate = try _degenerate()
        
        for component in degenerate.components {
            try container.encode(component)
        }
    }
}

extension AbstractLLM.ChatMessage {
    /// FIXME!!!
    public func _stripToText() throws -> String {
        try content._stripToText()
    }
}

extension AbstractLLM.ChatPrompt {
    /// FIXME!!!
    public func _stripToText() throws -> String {
        try messages.map({ try $0._stripToText() }).joined()
    }
}

extension AbstractLLM.ChatCompletion {
    public func _stripToText() throws -> String {
        try message.content._stripToText()
    }
}

extension AbstractLLM.ChatOrTextCompletion {
    public func _stripToText() throws -> String {
        switch self {
            case .text(let completion):
                return completion.text
            case .chat(let completion):
                return try completion._stripToText()
        }
    }
}

extension PromptLiteral {
    public func _stripToText() throws -> String {
        try stringInterpolation.components.map({ try $0._stripToText() }).joined()
    }
}

extension PromptLiteral.StringInterpolation.Component {
    @_spi(Internal)
    public func _stripToText() throws -> String {
        switch payload {
            case .stringLiteral(let value):
                return value
            case .image:
                throw Never.Reason.illegal
            case .localizedStringResource(let value):
                return try value._toNSLocalizedString()
            case .promptLiteralConvertible(let value):
                return try value.promptLiteral.merging(context)._stripToText()
            case .dynamicVariable(let variable):
                return try variable.promptLiteral._stripToText()
            case .other(let other):
                switch other {
                    case .functionCall:
                        throw Never.Reason.illegal
                    case .functionInvocation:
                        throw Never.Reason.illegal
                }
        }
    }
}
