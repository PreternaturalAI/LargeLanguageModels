//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import Foundation
import Swallow

public protocol _MLModelIdentifierConvertible {
    func _toMLModelIdentifier() -> _MLModelIdentifierConvertible
}

/// A general purpose type to identify distinct machine-learning models.
///
/// It's intended for use with both local and API-only models.
public struct _MLModelIdentifier: HadeanIdentifiable, Hashable, Sendable {
    public static var hadeanIdentifier: HadeanIdentifier {
        "ludab-gulor-porin-zuvok"
    }
    
    public let provider: _AIModelProvider
    public let name: String
    public let revision: String?
    
    public var description: String {
        provider.rawValue + "/" + name
    }
    
    public init(
        provider: _AIModelProvider,
        name: String,
        revision: String?
    ) {
        self.provider = provider
        self.name = name
        self.revision = revision
    }
    
    public init?(description: String) {
        let components = description.components(separatedBy: "/")
        
        guard components.count == 2 else {
            return nil
        }
        
        self.init(
            provider: .init(rawValue: components.first!),
            name: components.last!,
            revision: nil
        )
    }
}

extension _MLModelIdentifier: Codable {
    public enum CodingKeys {
        case provider
        case name
        case revision
    }
    
    private struct _WithRevisionRepresentaton: Codable, Hashable {
        let provider: _AIModelProvider
        let name: String
        let revision: String
    }
    
    public init(from decoder: Decoder) throws {
        let containerKind = try decoder._determineContainerKind()
        
        switch containerKind {
            case .singleValue:
                self = try Self(description: String(from: decoder)).unwrap()
            case .unkeyed:
                throw Never.Reason.illegal
            case .keyed:
                let representation = try _WithRevisionRepresentaton(from: decoder)
                
                self.init(
                    provider: representation.provider,
                    name: representation.name,
                    revision: representation.revision
                )
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        if let revision {
            try _WithRevisionRepresentaton(
                provider: provider,
                name: name,
                revision: revision
            )
            .encode(to: encoder)
        } else {
            try description.encode(to: encoder)
        }
    }
}

public enum _AIModelProvider: HadeanIdentifiable, Hashable, Sendable {
    public static var hadeanIdentifier: HadeanIdentifier {
        "bagog-golir-jisap-mozop"
    }
    
    case apple
    case openAI
    case anthropic
    case unknown(String)
}

extension _AIModelProvider: CustomStringConvertible {
    public var description: String {
        switch self {
            case .apple:
                return "Apple"
            case .openAI:
                return "OpenAI"
            case .anthropic:
                return "Anthropic"
            case .unknown(let provider):
                return provider
        }
    }
}

extension _AIModelProvider: RawRepresentable {
    public var rawValue: String {
        switch self {
            case .apple:
                return "apple"
            case .openAI:
                return "openai"
            case .anthropic:
                return "anthropic"
            case .unknown(let provider):
                return provider
        }
    }
    
    public init(rawValue: String) {
        switch rawValue {
            case Self.openAI.rawValue:
                self = .openAI
            case Self.anthropic.rawValue:
                self = .anthropic
            default:
                self = .unknown(rawValue)
        }
    }
}

extension _AIModelProvider: Codable {
    public init(from decoder: Decoder) throws {
        try self.init(rawValue: String(from: decoder))
    }
    
    public func encode(to encoder: Encoder) throws {
        try rawValue.encode(to: encoder)
    }
}
