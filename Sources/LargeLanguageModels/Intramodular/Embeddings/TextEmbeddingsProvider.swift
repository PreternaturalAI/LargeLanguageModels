//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import Merge
import Swallow

/// A type that provides vector embeddings for text.
public protocol TextEmbeddingsProvider {
    func fulfill(
        _ request: TextEmbeddingsGenerationRequest
    ) async throws -> TextEmbeddings
}

// MARK: - Extensions

extension TextEmbeddingsProvider {
    public func textEmbeddings(
        for strings: [String]
    ) async throws -> TextEmbeddings {
        try await self.fulfill(.init(model: nil, strings: strings))
    }
    
    public func textEmbedding(
        for string: String
    ) async throws -> _RawTextEmbedding {
        try await self.fulfill(.init(model: nil, strings: [string]))
            .data
            .toCollectionOfOne()
            .value
            .embedding
    }
}

// MARK: - Diagnostics

public enum TextEmbeddingsProviderError: Error {
    case tokenLimitExceeded
}

// MARK: - Auxiliary

public struct TextEmbeddingsGenerationRequest {
    public let model: _MLModelIdentifier?
    public let strings: [String]
    
    public init(model: _MLModelIdentifier?, strings: [String]) {
        self.model = model
        self.strings = strings
    }
    
    public func batched(batchSize: Int) -> [Self] {
        strings.chunked(by: batchSize).map { chunk in
            Self(
                model: model,
                strings: Array(chunk)
            )
        }
    }
}
