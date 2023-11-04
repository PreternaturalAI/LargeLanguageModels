//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import Swallow

/// A type that represents an array of text embeddings.
///
/// Text embeddings are vector representations of text.
///
/// You can produce text embeddings by using a text embedding model (for e.g. OpenAI's `text-embedding-ada-002`).
public struct TextEmbeddings: Codable, HadeanIdentifiable, Hashable, Sendable {
    public static var hadeanIdentifier: HadeanIdentifier {
        "junur-tutuz-zarik-ninab"
    }
    
    public let model: _MLModelIdentifier
    public let data: [Element]
    
    public init(
        model: _MLModelIdentifier,
        data: [Element]
    ) {
        self.model = model
        self.data = data
    }
    
    public func appending(contentsOf other: TextEmbeddings) -> Self {
        assert(model == other.model)
        
        return .init(model: model, data: data.appending(contentsOf: other.data))
    }
}

extension TextEmbeddings {
    public struct Element: HadeanIdentifiable, Hashable, Sendable {
        public static var hadeanIdentifier: HadeanIdentifier {
            "dapup-numuz-koluh-goduv"
        }
        
        public let text: String
        public let embedding: _RawTextEmbedding
        
        public init(text: String, embedding: _RawTextEmbedding) {
            self.text = text
            self.embedding = embedding
        }
        
        public init(text: String, embedding: _RawTextEmbedding.RawValue) {
            self.init(text: text, embedding: .init(rawValue: embedding))
        }
    }
}

// MARK: - Conformances

extension TextEmbeddings.Element: Codable {
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

extension TextEmbeddings: RandomAccessCollection {
    public var startIndex: Int {
        data.startIndex
    }
    
    public var endIndex: Int {
        data.endIndex
    }

    public subscript(_ index: Int) -> Element {
        data[index]
    }
    
    public func makeIterator() -> AnyIterator<Element> {
        data.makeIterator().eraseToAnyIterator()
    }
}
