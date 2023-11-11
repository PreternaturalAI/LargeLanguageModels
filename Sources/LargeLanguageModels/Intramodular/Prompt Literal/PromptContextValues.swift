//
// Copyright (c) Vatsal Manot
//

import Swallow

public protocol PromptContextKey<Value>: HeterogeneousDictionaryKey<PromptContextValues, Self.Value> {
    static var defaultValue: Value { get }
}

public struct PromptContextValues {
    @_spi(Private)
    @TaskLocal public static var _current = Self()
    
    public static var current: Self {
        get {
            _current
        }
    }
    
    private var storage: HeterogeneousDictionary<PromptContextValues>
    
    fileprivate init() {
        self.storage = .init()
    }
    
    public subscript<Key: PromptContextKey>(key: Key.Type) -> Key.Value {
        get {
            storage[key] ?? key.defaultValue
        } set {
            storage[key] = newValue
        }
    }
}

// MARK: - Conformances

extension PromptContextValues: ThrowingMergeOperatable {
    public mutating func mergeInPlace(with other: Self) throws {
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
    private struct CompletionTypeKey: PromptContextKey {
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
