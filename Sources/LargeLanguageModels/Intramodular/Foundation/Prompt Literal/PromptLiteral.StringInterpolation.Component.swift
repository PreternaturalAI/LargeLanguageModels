//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import Foundation
import Swallow

extension PromptLiteral.StringInterpolation {
    public struct Component: Hashable, Sendable {
        public enum Payload: HashEquatable, @unchecked Sendable {
            public enum Other: Hashable, Sendable {
                case functionCall(AbstractLLM.ChatPrompt.FunctionCall)
                case functionInvocation(AbstractLLM.ChatPrompt.FunctionInvocation)
                
                var rawValue: any Hashable {
                    switch self {
                        case .functionCall(let call):
                            return call
                        case .functionInvocation(let invocation):
                            return invocation
                    }
                }
                
                var value: any Hashable {
                    rawValue
                }
            }
            
            case stringLiteral(String)
            case localizedStringResource(LocalizedStringResource)
            case promptLiteralConvertible(any PromptLiteralConvertible)
            case dynamicVariable(any _opaque_DynamicPromptVariable)
            case other(Other)
        }
        
        public var payload: Payload
        public var context: PromptLiteralContext
                
        public init(payload: Payload, context: PromptLiteralContext) {
            self.payload = payload
            self.context = context
            
            if case .promptLiteralConvertible(let value) = payload {
                assert(!(value is any _opaque_DynamicPromptVariable))
            }
        }
    }
}

// MARK: - Conformances

extension PromptLiteral.StringInterpolation.Component: CustomStringConvertible {
    public var description: String {
        String(describing: payload)
    }
}

extension PromptLiteral.StringInterpolation.Component: Codable {
    public init(from decoder: Decoder) throws {
        self.payload = try Payload(from: decoder)
        self.context = .init()
    }
    
    public func encode(to encoder: Encoder) throws {
        assert(context.isEmpty, "unimplemented")

        try payload.encode(to: encoder)
    }
}

extension PromptLiteral.StringInterpolation.Component.Payload: Codable {
    public init(from decoder: Decoder) throws {
        if let value = try? String(from: decoder) {
            self = .stringLiteral(value)
        } else {
            throw Never.Reason.unimplemented
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        switch self {
            case .stringLiteral(let value):
                try value.encode(to: encoder)
            default:
                throw Never.Reason.unimplemented
        }
    }
}

extension PromptLiteral.StringInterpolation.Component.Payload: Hashable {
    public func hash(into hasher: inout Hasher) {
        do {
            try _HashableExistential(erasing: value).hash(into: &hasher)
        } catch {
            assertionFailure()
        }
    }
}

extension PromptLiteral.StringInterpolation.Component.Payload: ThrowingRawValueConvertible {
    public typealias RawValue = Any
    
    public var rawValue: Any {
        get throws {
            switch self {
                case .stringLiteral(let value):
                    return value
                case .localizedStringResource(let value):
                    return value
                case .promptLiteralConvertible(let value):
                    return value
                case .dynamicVariable(let variable):
                    return variable
                case .other(let other):
                    return other.rawValue
            }
        }
    }
    
    public var value: Any {
        get throws {
            switch self {
                case .stringLiteral(let value):
                    return value
                case .localizedStringResource(let value):
                    return try value._toNSLocalizedString()
                case .promptLiteralConvertible(let value):
                    return try value.promptLiteral
                case .dynamicVariable:
                    assertionFailure()
                    
                    throw Never.Reason.illegal
                case .other(let other):
                    return other.value
            }
        }
    }
}

// MARK: - Internal

extension PromptLiteral.StringInterpolation.Component {
    @_spi(Internal)
    public func _stripToText() throws -> String {
        switch payload {
            case .stringLiteral(let value):
                return value
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
