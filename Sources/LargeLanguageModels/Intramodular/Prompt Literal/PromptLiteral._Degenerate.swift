//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

extension PromptLiteral {
    /// A partially resolved version of the `PromptLiteral`.
    public struct _Degenerate {
        public struct Component {
            public let payload: Payload
            public let context: PromptLiteralContext
        }
        
        public let components: [Component]
    }
}

@_spi(Internal)
extension PromptLiteral {
    public enum _DegenerationError: Error {
        case dynamicVariableUnresolved(any _opaque_DynamicPromptVariable)
    }
    
    public func _degenerate() throws -> _Degenerate {
        var components: [_Degenerate.Component] = []
        
        func append(_ component: _Degenerate.Component) throws {
            if let last = components.last, component.payload.type == last.payload.type {
                let merged = try last.appending(contentsOf: component)
                
                components.mutableLast = merged
            } else {
                components.append(component)
            }
        }
        
        for component in stringInterpolation.components {
            switch component.payload {
                case .stringLiteral(let string):
                    try append(
                        _Degenerate.Component(
                            payload: .string(string),
                            context: component.context
                        )
                    )
                case .image(let image):
                    try append(
                        _Degenerate.Component(
                            payload: .image(image),
                            context: component.context
                        )
                    )
                case .localizedStringResource(let resource):
                    try append(
                        _Degenerate.Component(
                            payload: .string(try resource._toNSLocalizedString()),
                            context: component.context
                        )
                    )
                case .promptLiteralConvertible(let convertible):
                    let subcomponents = try convertible
                        .promptLiteral
                        .merging(component.context)
                        ._degenerate()
                        .components
                    
                    for subcomponent in subcomponents {
                        try append(subcomponent)
                    }
                case .dynamicVariable(let variable):
                    do {
                        let subcomponents = try variable
                            .promptLiteral
                            .merging(component.context)
                            ._degenerate()
                            .components
                        
                        for subcomponent in subcomponents {
                            try append(subcomponent)
                        }
                    } catch {
                        throw _DegenerationError.dynamicVariableUnresolved(variable)
                    }
                case .other(let other):
                    switch other {
                        case .functionCall(let call):
                            try append(
                                _Degenerate.Component(payload: .functionCall(call), context: component.context)
                            )
                        case .functionInvocation(let invocation):
                            try append(
                                _Degenerate.Component(
                                    payload: .functionInvocation(invocation),
                                    context: component.context
                                )
                            )
                    }
            }
        }
        
        return _Degenerate(components: components)
    }
}

extension PromptLiteral._Degenerate {
    @_spi(Internal)
    public func _getFunctionCallOrInvocation() throws -> Any? {
        if components.contains(where: { $0.payload.type == .functionCall || $0.payload.type == .functionInvocation }) {
            switch try components.toCollectionOfOne().value.payload {
                case .functionCall(let call):
                    return call
                case .functionInvocation(let invocation):
                    return invocation
                default:
                    throw Never.Reason.illegal
            }
        } else {
            return nil
        }
    }
}

// MARK: - Auxiliary

extension PromptLiteral._Degenerate.Component {
    public enum PayloadType {
        case string
        case image
        case functionCall
        case functionInvocation
    }
    
    public enum Payload {
        public typealias Image = PromptLiteral.StringInterpolation.Component.Payload.Image
        
        case string(String)
        case image(Image)
        case functionCall(AbstractLLM.ChatPrompt.FunctionCall)
        case functionInvocation(AbstractLLM.ChatPrompt.FunctionInvocation)
        
        public var type: PayloadType {
            switch self {
                case .string:
                    return .string
                case .image:
                    return .image
                case .functionCall:
                    return .functionCall
                case .functionInvocation:
                    return .functionCall
            }
        }
    }
}

extension PromptLiteral._Degenerate.Component {
    @_spi(Internal)
    public mutating func append(contentsOf other: Self) throws {
        guard self.context == other.context else {
            throw Never.Reason.illegal
        }
        
        switch (self.payload, other.payload) {
            case (.string(let lhs), .string(let rhs)):
                self = .init(payload: .string(lhs + rhs), context: self.context)
            case (.functionCall, .functionCall):
                throw Never.Reason.illegal
            case (.functionInvocation, .functionInvocation):
                throw Never.Reason.illegal
            default:
                assertionFailure()
                
                throw Never.Reason.illegal
        }
    }
    
    @_spi(Internal)
    public func appending(contentsOf other: Self) throws -> Self {
        try build(self) {
            try $0.append(contentsOf: $0)
        }
    }
}
