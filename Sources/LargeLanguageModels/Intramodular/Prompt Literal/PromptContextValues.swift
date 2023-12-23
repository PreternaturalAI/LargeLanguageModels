//
// Copyright (c) Vatsal Manot
//

import CoreGML
import CorePersistence
import Swallow

public protocol PromptContextKey<Value>: HadeanIdentifiable, HeterogeneousDictionaryKey<PromptContextValues, Self.Value>, Sendable {
    static var defaultValue: Value { get }
}

public struct PromptContextValues: Codable, Hashable, Initiable, @unchecked Sendable {
    @_spi(Private)
    @TaskLocal public static var _current = Self()
    
    public static var current: Self {
        get {
            _current
        }
    }
    
    @_UnsafelySerialized
    private var storage: HeterogeneousDictionary<PromptContextValues>
    
    public init() {
        self.storage = .init()
    }
    
    public subscript<Key: PromptContextKey>(key: Key.Type) -> Key.Value {
        get {
            storage[key] ?? key.defaultValue
        } set {
            storage[key] = newValue
        }
    }
    
    @_disfavoredOverload
    public func get<T>(_ keyPath: KeyPath<Self, T?>) throws -> T {
        try self[keyPath: keyPath].unwrap()
    }
    
    public func get<T>(_ keyPath: KeyPath<Self, T?>) -> T? {
        self[keyPath: keyPath]
    }
}

// MARK: - Conformances

extension PromptContextValues: ThrowingMergeOperatable {
    public mutating func mergeInPlace(
        with other: Self
    ) throws {
        try storage.merge(other.storage, uniquingKeysWith: { (lhs, rhs) -> Any in
            if let lhs = lhs as? any ThrowingMergeOperatable {
                return try lhs._opaque_merging(rhs)
            } else {
                if AnyEquatable.equate(lhs, rhs) {
                    return lhs
                } else {
                    throw Never.Reason.illegal
                }
            }
        })
    }
}

extension PromptContextValues {
    @HadeanIdentifier("rakik-kafun-laluj-bakih")
    @RuntimeDiscoverable
    struct CompletionTypeKey: PromptContextKey {
        typealias Value = AbstractLLM.CompletionType?
        
        static var defaultValue: AbstractLLM.CompletionType? = nil
    }
    
    public var completionType: AbstractLLM.CompletionType? {
        get {
            self[CompletionTypeKey.self]
        } set {
            self[CompletionTypeKey.self] = newValue
        }
    }
    
    @HadeanIdentifier("povom-dimiz-fuzuz-hataf")
    @RuntimeDiscoverable
    struct CompletionParametersKey: PromptContextKey {
        typealias Value = (any AbstractLLM.CompletionParameters)?
        
        static var defaultValue: (any AbstractLLM.CompletionParameters)? = nil
    }
    
    public var completionParameters: (any AbstractLLM.CompletionParameters)? {
        get {
            self[CompletionParametersKey.self]
        } set {
            self[CompletionParametersKey.self] = newValue
        }
    }
    
    @HadeanIdentifier("vipan-nutar-gutah-limin")
    @RuntimeDiscoverable
    struct ModelIdentifierKey: PromptContextKey {
        typealias Value = _GMLModelIdentifierScope?
        
        static var defaultValue: _GMLModelIdentifierScope? = nil
    }
    
    public var modelIdentifier: _GMLModelIdentifierScope? {
        get {
            self[ModelIdentifierKey.self]
        } set {
            self[ModelIdentifierKey.self] = newValue
        }
    }
}

// MARK: - API

public func _withPromptContext<Result>(
    _ updateContextForOperation: (inout PromptContextValues) throws -> Void,
    operation: () throws -> Result
) rethrows -> Result {
    var context = PromptContextValues.current
    
    try updateContextForOperation(&context)
    
    return try PromptContextValues.$_current.withValue(context) {
        try operation()
    }
}

public func _withPromptContext<Result>(
    _ updateContextForOperation: (inout PromptContextValues) async throws -> Void,
    operation: () async throws -> Result
) async rethrows -> Result {
    var context = PromptContextValues.current
    
    try await updateContextForOperation(&context)
    
    return try await PromptContextValues.$_current.withValue(context) {
        try await operation()
    }
}

public func _withPromptContext<Result>(
    _ context: PromptContextValues,
    operation: () throws -> Result
) throws -> Result {
    let current = PromptContextValues.current
    let new = try current.merging(context)
    
    return try PromptContextValues.$_current.withValue(new) {
        try operation()
    }
}

public func _withPromptContext<Result>(
    _ context: PromptContextValues,
    operation: () async throws -> Result
) async throws -> Result {
    let current = PromptContextValues.current
    let new = try current.merging(context)
    
    return try await PromptContextValues.$_current.withValue(new) {
        try await operation()
    }
}
