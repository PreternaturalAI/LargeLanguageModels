//
// Copyright (c) Vatsal Manot
//

import Swallow

public protocol PromptLiteralContextKey<Value>: HeterogeneousDictionaryKey<PromptContextValues, Self.Value> where Value: Hashable {
    static var defaultValue: Value { get }
}

public struct PromptLiteralContext: HashEquatable, @unchecked Sendable {
    public enum _Error: Error {
        case badMerge
    }
    
    fileprivate var storage: HeterogeneousDictionary<PromptContextValues>
    
    public var isEmpty: Bool {
        storage.isEmpty
    }
    
    public init() {
        self.storage = .init()
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
            let pair = Hashable2ple((Metatype($0.key), _HashableExistential(wrappedValue: $0.value)))
            
            hasher.combine(pair)
        }
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

extension PromptLiteral.StringInterpolation.Component {
    mutating func merge(
        _ context: PromptLiteralContext
    ) throws {
        try self.context.mergeInPlace(with: context)
    }
}

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
