//
// Copyright (c) Vatsal Manot
//

import NaturalLanguage
import Swallow

public final class NLEmbeddingProvider: TextEmbeddingsProvider {
    public enum EmbeddingType {
        case word
        case sentence
    }
    
    public let embeddingType: EmbeddingType
    public let language: NLLanguage
    
    public init(
        embeddingType: EmbeddingType,
        language: NLLanguage
    ) {
        self.embeddingType = embeddingType
        self.language = language
    }
    
    public var model: _MLModelIdentifier {
        get throws {
            let languageName = try NLLanguage.Name(language).unwrap().rawValue
            
            switch embeddingType {
                case .word:
                    return .init(
                        provider: .apple,
                        name: "word-embedding-\(languageName)",
                        revision: NLEmbedding.currentRevision(for: language).description
                    )
                case .sentence:
                    return .init(
                        provider: .apple,
                        name: "sentence-embedding-\(languageName)",
                        revision: NLEmbedding.currentRevision(for: language).description
                    )
            }
        }
    }
    
    public func fulfill(
        _ request: TextEmbeddingsGenerationRequest
    ) async throws -> TextEmbeddings {
        let embedding: NLEmbedding
        
        if let requestedModel = request.model {
            try _tryAssert(requestedModel == model)
        }
        
        switch embeddingType {
            case .word:
                embedding = try NLEmbedding.wordEmbedding(for: language).unwrap()
            case .sentence:
                embedding = try NLEmbedding.sentenceEmbedding(for: language).unwrap()
        }
        
        return try TextEmbeddings(
            model: model,
            data:  request.strings.map { string in
                _RawTextEmbeddingPair(
                    text: string,
                    embedding: .init(rawValue: try embedding.vector(for: string).unwrap())
                )
            }
        )
    }
}
