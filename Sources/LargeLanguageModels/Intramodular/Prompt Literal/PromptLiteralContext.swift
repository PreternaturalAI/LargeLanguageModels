//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import Swallow

public protocol PromptLiteralContextKey<Value>: HadeanIdentifiable, HeterogeneousDictionaryKey<PromptContextValues, Self.Value> where Value: Hashable {
    static var defaultValue: Value { get }
}

public struct PromptLiteralContext: Codable, HashEquatable, @unchecked Sendable {
    public enum _Error: Error {
        case badMerge
    }
    
    @_UnsafelySerialized
    var storage: HeterogeneousDictionary<PromptContextValues>
    
    public var isEmpty: Bool {
        storage.isEmpty
    }
    
    init(storage: HeterogeneousDictionary<PromptContextValues>) {
        self.storage = storage
    }
    
    public init() {
        self.init(storage: .init())
    }
    
    public subscript<Key: PromptLiteralContextKey>(key: Key.Type) -> Key.Value {
        get {
            storage[key] ?? key.defaultValue
        } set {
            storage[key] = newValue
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        storage.forEach {
            let pair = Hashable2ple(($0.key, _HashableExistential(wrappedValue: $0.value)))
            
            hasher.combine(pair)
        }
    }
    
    func removingValues(_ keys: some Sequence<any PromptLiteralContextKey.Type>) -> Self {
        Self(storage: storage.removingValues(forKeys: keys.map({ $0 as Any.Type })))
    }
}

// MARK: - Conformances

extension PromptLiteralContext: CustomStringConvertible {
    public var description: String {
        storage.description
    }
}

extension PromptLiteralContext: Sequence {
    public func makeIterator() -> HeterogeneousDictionary<PromptContextValues>.Iterator {
        storage.makeIterator()
    }
}

extension PromptLiteralContext: ThrowingMergeOperatable {
    public mutating func mergeInPlace(with other: Self) throws {
        try storage.merge(other.storage, uniquingKeysWith: { (lhs, rhs) -> Any in
            if let lhs = lhs as? any ThrowingMergeOperatable {
                return try lhs._opaque_merging(rhs)
            } else {
                if AnyEquatable.equate(lhs, rhs) {
                    return lhs
                } else {
                    throw _Error.badMerge
                }
            }
        })
    }
}

// MARK: - Auxiliary

extension PromptLiteral {
    public mutating func merge(
        _ context: PromptLiteralContext
    ) throws {
        try self.stringInterpolation.components._forEach(mutating: {
            try $0.merge(context)
        })
    }
    
    public func merging(
        _ context: PromptLiteralContext
    ) throws -> Self {
        try build(self) {
            try $0.merge(context)
        }
    }
    
    public func context<Value>(
        _ keyPath: WritableKeyPath<PromptLiteralContext, Value>,
        _ value: Value
    ) throws -> PromptLiteral {
        try merging(build(PromptLiteralContext()) {
            $0[keyPath: keyPath] = value
        })
    }
    
    public func _context<Value>(
        _ keyPath: WritableKeyPath<PromptLiteralContext, Value>,
        _ value: Value
    ) -> PromptLiteral {
        with(self) {
            $0.stringInterpolation.components._forEach(mutating: {
                $0.context[keyPath: keyPath] = value
            })
        }
    }
}

extension PromptLiteral.StringInterpolation.Component {
    mutating func merge(
        _ context: PromptLiteralContext
    ) throws {
        try self.context.mergeInPlace(with: context)
    }
}
