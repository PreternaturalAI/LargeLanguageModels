//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

extension PromptLiteral {
    public struct _Degenerate {
        public struct Component {
            public enum PayloadType {
                case string
                case image
                case dynamicVariable
                case functionCall
                case functionInvocation
            }
            
            public enum Payload {
                public typealias Image = PromptLiteral.StringInterpolation.Component.Payload.Image
                
                case string(String)
                case image(Image)
                case dynamicVariable(any _opaque_DynamicPromptVariable)
                case functionCall(AbstractLLM.ChatPrompt.FunctionCall)
                case functionInvocation(AbstractLLM.ChatPrompt.FunctionInvocation)
                
                public var type: PayloadType {
                    switch self {
                        case .string:
                            return .string
                        case .image:
                            return .image
                        case .dynamicVariable:
                            return .dynamicVariable
                        case .functionCall:
                            return .functionCall
                        case .functionInvocation:
                            return .functionCall
                    }
                }
            }
            
            public let payload: Payload
            public let context: PromptLiteralContext
            
            mutating func append(contentsOf other: Self) throws {
                guard self.context == other.context else {
                    throw Never.Reason.illegal
                }
                
                switch (self.payload, other.payload) {
                    case (.string(let lhs), .string(let rhs)):
                        self = .init(payload: .string(lhs + rhs), context: self.context)
                    case (.dynamicVariable, .dynamicVariable):
                        throw Never.Reason.illegal
                    case (.functionCall, .functionCall):
                        throw Never.Reason.illegal
                    case (.functionInvocation, .functionInvocation):
                        throw Never.Reason.illegal
                    default:
                        throw Never.Reason.illegal
                }
            }
            
            func appending(contentsOf other: Self) throws -> Self {
                try build(self) {
                    try $0.append(contentsOf: $0)
                }
            }
        }
        
        public let components: [Component]
    }
    
    public func _degenerate() throws -> _Degenerate {
        var components: [_Degenerate.Component] = []
        
        func append(_ component: _Degenerate.Component) {
            if let last = components.last, component.payload.type != .image {
                do {
                    let merged = try last.appending(contentsOf: component)
                    
                    components.mutableLast = merged
                } catch {
                    components.append(component)
                }
            } else {
                components.append(component)
            }
        }
        
        for component in stringInterpolation.components {
            switch component.payload {
                case .stringLiteral(let string):
                    append(.init(payload: .string(string), context: component.context))
                case .image(let image):
                    append(.init(payload: .image(image), context: component.context))
                case .localizedStringResource(let resource):
                    append(.init(payload: .string(try resource._toNSLocalizedString()), context: component.context))
                case .promptLiteralConvertible(let convertible):
                    let subcomponents = try convertible
                        .promptLiteral
                        .merging(component.context)
                        ._degenerate()
                        .components
                    
                    for subcomponent in subcomponents {
                        append(subcomponent)
                    }
                case .dynamicVariable(let variable):
                    append(.init(payload: .dynamicVariable(variable), context: component.context))
                case .other(let other):
                    switch other {
                        case .functionCall(let call):
                            append(.init(payload: .functionCall(call), context: component.context))
                        case .functionInvocation(let invocation):
                            append(.init(payload: .functionInvocation(invocation), context: component.context))
                    }
            }
        }
        
        return .init(components: components)
    }
}

extension PromptLiteral._Degenerate {
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
