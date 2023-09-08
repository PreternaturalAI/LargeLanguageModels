//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import HadeanIdentifiers
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
    public let data: [_RawTextEmbeddingPair]
    
    public init(
        model: _MLModelIdentifier,
        data: [_RawTextEmbeddingPair]
    ) {
        self.model = model
        self.data = data
    }
    
    public func appending(contentsOf other: TextEmbeddings) -> Self {
        assert(model == other.model)
        
        return .init(model: model, data: data.appending(contentsOf: other.data))
    }
}
