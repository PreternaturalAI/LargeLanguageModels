//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import Foundation
import Swallow

extension PromptLiteral {
    public struct StringInterpolation: Hashable, Sendable, StringInterpolationProtocol {        
        public var components: [Component]
        
        /// The context shared amongst all the components.
        public var _sharedContext: PromptLiteralContext {
            get {
                let shared = components.map({ Dictionary($0.context.storage) })
                    .sharedKeysByEqualValue(where: {
                        try! _HashableExistential(erasing: $0) == _HashableExistential(erasing: $1)
                    })
                
                return PromptLiteralContext(storage: .init(_unsafeStorage: shared))
            } set {
                components._forEach(mutating: {
                    try! $0.context.mergeInPlace(with: newValue)
                })
            }
        }
        
        public init(components: some Collection<Component>) {
            self.components = .init(components)
        }
        
        @_spi(Internal)
        public init(
            payload: StringInterpolation.Component.Payload,
            role: PromptMatterRole? = nil
        ) {
            var context = PromptLiteralContext()
            
            if let role {
                context.role = .selected(role)
            }
            
            let component = StringInterpolation.Component(
                payload: payload,
                context: context
            )
            
            self.init(components: [component])
        }
        
        public init(literalCapacity: Int, interpolationCount: Int) {
            self.init(components: Array(capacity: literalCapacity + interpolationCount))
        }
        
        public init() {
            self.init(components: [])
        }
    }
}

extension PromptLiteral.StringInterpolation.Component.Payload: _MaybeAsyncProtocol {
    public var _isKnownAsync: Bool? {
        switch self {
            case .stringLiteral:
                return false
            case .image:
                return nil
            case .localizedStringResource:
                return false
            case .promptLiteralConvertible(let variable):
                return (variable as? _MaybeAsyncProtocol)?._isKnownAsync
            case .dynamicVariable(let variable):
                return (variable as? _MaybeAsyncProtocol)?._isKnownAsync
            case .other:
                return false
        }
    }

    public func _resolveToNonAsync() async throws -> Self {
        switch self {
            case .stringLiteral:
                return self
            case .image:
                throw Never.Reason.unimplemented
            case .localizedStringResource:
                return self
            case .promptLiteralConvertible(let variable):
                return .promptLiteralConvertible(try await _resolveMaybeAsync(variable))
            case .dynamicVariable(let variable):
                return .dynamicVariable(try await _resolveMaybeAsync(variable))
            case .other:
                return self
        }
    }
}

extension PromptLiteral.StringInterpolation.Component: _MaybeAsyncProtocol {
    public var _isKnownAsync: Bool? {
        payload._isKnownAsync
    }
    
    public func _resolveToNonAsync() async throws -> Self {
        try await .init(payload: self.payload._resolveToNonAsync(), context: context)
    }
}

extension PromptLiteral.StringInterpolation: _MaybeAsyncProtocol {
    public func _resolveToNonAsync() async throws -> Self {
        .init(components: try await components.asyncMap {
            .init(payload: try await $0.payload._resolveToNonAsync(), context: $0.context)
        })
    }
}

extension PromptLiteral: _MaybeAsyncProtocol {
    public func _resolveToNonAsync() async throws -> PromptLiteral {
        try await .init(stringInterpolation: stringInterpolation._resolveToNonAsync())
    }
}

extension PromptLiteral.StringInterpolation {
    public mutating func appendLiteral(
        _ literal: String
    ) {
        components.append(.init(payload: .stringLiteral(literal), context: .init()))
    }
    
    public mutating func appendLiteral(
        _ literal: PromptLiteral
    ) {
        components.append(contentsOf: literal.stringInterpolation.components)
    }
    
    public mutating func appendLiteral(
        _ literal: any PromptLiteralConvertible
    ) {
        if let variable = literal as? (any _opaque_DynamicPromptVariable) {
            components.append(.init(payload: .dynamicVariable(variable), context: .init()))
        } else {
            appendLiteral(PromptLiteral(_lazy: literal))
        }
    }
    
    public mutating func appendInterpolation(
        _ interpolation: PromptLiteral
    ) {
        components.append(
            contentsOf: interpolation.stringInterpolation.components,
            join: PromptLiteral.StringInterpolation.Component._join
        )
    }
    
    public mutating func appendInterpolation(
        _ interpolation: String
    ) {
        appendInterpolation(PromptLiteral(stringLiteral: interpolation))
    }
    
    public mutating func appendInterpolation(
        _ interpolation: any PromptLiteralConvertible
    ) {
        if let variable = interpolation as? (any _opaque_DynamicPromptVariable) {
            components.append(Component(payload: .dynamicVariable(variable), context: .init()))
        } else {
            appendInterpolation(PromptLiteral(_lazy: interpolation))
        }
    }
}

extension PromptLiteral.StringInterpolation.Component {
    static func _join(_ lhs: Self, _ rhs: Self) -> Self? {
        guard let context = try? lhs.context.merging(rhs.context) else {
            return nil
        }
        
        let payload: Payload
        
        switch (lhs.payload, rhs.payload) {
            case (.stringLiteral(let lhs), .stringLiteral(let rhs)):
                payload = .stringLiteral(lhs + rhs)
            default:
                return nil
        }
        
        return Self(payload: payload, context: context)
    }
}

extension RangeReplaceableCollection where Self: BidirectionalCollection & MutableCollection {
    public mutating func append(
        contentsOf newElements: some Sequence<Element>,
        join: (Element, Element) -> Element?
    ) {
        for element in newElements {
            if let last, let joined = join(last, element) {
                self.mutableLast = joined
            } else {
                self.append(element)
            }
        }
    }
}

extension PromptLiteral {
    public mutating func insert(
        _ component: StringInterpolation.Component
    ) {
        stringInterpolation.components.append(component)
    }

    public mutating func insert(
        contentsOf components: some Sequence<StringInterpolation.Component>
    ) {
        stringInterpolation.components.insert(contentsOf: components)
    }

    public mutating func insert(
        _ component: StringInterpolation.Component.Payload
    ) {
        insert(.init(payload: component, context: .init()))
    }

    @_spi(Private)
    public func inserting(
        contentsOf components: some Sequence<StringInterpolation.Component>
    ) -> Self {
        build(self) {
            $0.insert(contentsOf: components)
        }
    }

    public mutating func append(
        _ component: StringInterpolation.Component
    ) {
        stringInterpolation.components.append(component)
    }
    
    public mutating func append(
        _ component: StringInterpolation.Component.Payload
    ) {
        append(.init(payload: component, context: .init()))
    }
    
    public mutating func append(
        contentsOf components: some Sequence<StringInterpolation.Component>
    ) {
        stringInterpolation.components.append(contentsOf: components)
    }
    
    public func appending(
        _ component: StringInterpolation.Component
    ) -> Self {
        build(self) {
            $0.append(component)
        }
    }
    
    public func appending(
        contentsOf components: some Sequence<StringInterpolation.Component>
    ) -> Self {
        build(self) {
            $0.append(contentsOf: components)
        }
    }
}

extension PromptLiteral.StringInterpolation.Component {
    public var _isKnownString: Bool {
        switch payload {
            case .stringLiteral:
                return true
            case .image:
                return false
            case .localizedStringResource:
                return true
            case .promptLiteralConvertible:
                return false
            case .dynamicVariable:
                return false
            case .other:
                return false
        }
    }
}

extension PromptLiteral {
    /// Whether the entirety of this prompt literal is text.
    public var _isKnownString: Bool {
        get throws {
            guard try !isEmpty else {
                return false
            }
            
            return stringInterpolation.components.contains(where: { !$0._isKnownString }) == false
        }
    }
    
    /// Whether this prompt literal contains any images.
    public var _containsImages: Bool {
        get throws {
            guard try !isEmpty else {
                return false
            }
            
            return stringInterpolation.components.contains(where: { $0.payload._isImage })
        }
    }
}
