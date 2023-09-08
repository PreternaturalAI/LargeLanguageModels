//
// Copyright (c) Vatsal Manot
//

import Accelerate
import CorePersistence
import CoreTransferable
import HadeanIdentifiers
import Swallow

@frozen
public struct _RawTextEmbedding: Codable, CustomStringConvertible, Hashable, Sendable {
    public typealias RawValue = [Double]
    
    public let rawValue: RawValue
    
    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
    
    public var description: String {
        var result = rawValue.map {
            String(format: "%.3f", $0)
        }
            .joined(separator: ", ")
        
        result = "[" + result + "]"
        
        return result
    }
    
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

public struct _RawTextEmbeddingPair: HadeanIdentifiable, Hashable, Sendable {
    public static var hadeanIdentifier: HadeanIdentifier {
        "dapup-numuz-koluh-goduv"
    }
    
    public let text: String
    public let embedding: _RawTextEmbedding
    
    public init(text: String, embedding: _RawTextEmbedding) {
        self.text = text
        self.embedding = embedding
    }
}

// MARK: - Conformances

extension _RawTextEmbeddingPair: Codable {
    public enum CodingKeys: CodingKey {
        case text
        case embedding
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.text = try container.decode(forKey: .text)
        self.embedding = try container.decode(forKey: .embedding)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(text, forKey: .text)
        try container.encode(embedding, forKey: .embedding)
    }
}

extension _RawTextEmbeddingPair: Identifiable {
    public var id: String {
        text
    }
}
