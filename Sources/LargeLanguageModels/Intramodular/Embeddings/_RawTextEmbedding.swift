//
// Copyright (c) Vatsal Manot
//

import Accelerate
import CorePersistence
import CoreTransferable
import Swallow

/// A type that represents the embedding of a single text.
///
/// It is essentially just a wrapper around `Array<Double>` for now, but will expand to support various different forms of storage (including quantized representations).
@frozen
public struct _RawTextEmbedding: Hashable, Sendable {
    public typealias RawValue = [Double]
    
    public let rawValue: RawValue
    
    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
}

// MARK: - Implemented Conformances

extension _RawTextEmbedding: Codable {
    @inlinable
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        self.rawValue = try vDSP.floatToDouble(container.decode([Float].self))
    }
    
    @inlinable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        try container.encode(vDSP.doubleToFloat(rawValue))
    }
}

extension _RawTextEmbedding: CustomStringConvertible {
    public var description: String {
        var result = rawValue
            .map({ $0.formatted(toDecimalPlaces: 3) })
            .joined(separator: ", ")
        
        result = "[" + result + "]"
        
        return result
    }
}
