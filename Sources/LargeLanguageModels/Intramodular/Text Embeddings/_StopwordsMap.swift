//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

public struct _StopwordsMap {
    private let rawValue: [ISO639LanguageCode: Set<String>]
    
    private  init(rawValue: [ISO639LanguageCode: Set<String>]) {
        self.rawValue = rawValue
    }
    
    public subscript(_ language: ISO639LanguageCode) -> Set<String> {
        get throws {
            try rawValue[language].unwrap()
        }
    }
}

extension _StopwordsMap {
    public static let shared: Self = {
        do {
            return try Self.load()
        } catch {
            assertionFailure()
            
            return .init(rawValue: [:])
        }
    }()
    
    private static func load() throws -> Self {
        let filename = "stopwords-iso"
        
        let url = try Bundle.module.url(forResource: filename, withExtension: "json").unwrap()
        let data = try Data(contentsOf: url)
        let stopwords = try JSONDecoder().decode([String: [String]].self, from: data)
        
        return .init(
            rawValue: try stopwords
                .mapKeys {
                    try ISO639LanguageCode(rawValue: $0.uppercased()).unwrap()
                }
                .mapValues {
                    Set($0)
                }
        )
    }
}
