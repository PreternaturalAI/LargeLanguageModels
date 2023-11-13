//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import Foundation
import Swallow

public protocol _MLModelIdentifierConvertible {
    func _toMLModelIdentifier() throws -> _MLModelIdentifier
}

public protocol _MLModelIdentifierRepresentable: _MLModelIdentifierConvertible {
    init(from _: _MLModelIdentifier) throws
}

/// A general purpose type to identify distinct machine-learning models.
///
/// It's intended for use with both local and API-only models.
@HadeanIdentifier("ludab-gulor-porin-zuvok")
@RuntimeDiscoverable
public struct _MLModelIdentifier: Hashable, Sendable {
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
        
        guard !components.isEmpty else {
            assertionFailure()
            
            return nil
        }
        
        guard components.count == 2 else {
            if components.count == 1 {
                let component = components.first!
                
                if let model = _Anthropic_Model(rawValue: component) {
                    self.init(
                        provider: .anthropic,
                        name: model.rawValue,
                        revision: nil
                    )
                    
                    return
                } else if let model = _OpenAI_Model(rawValue: component) {
                    self.init(
                        provider: .openAI,
                        name: model.rawValue,
                        revision: nil
                    )
                    
                    return
                } else {
                    return nil
                }
            } else {
                return nil
            }
        }
        
        self.init(
            provider: .init(rawValue: components.first!),
            name: components.last!,
            revision: nil
        )
    }
}

// MARK: - Conformances

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
                let container = try decoder.singleValueContainer()
                
                self = try Self(description: container.decode(String.self)).unwrap()
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
    
    public func encode(
        to encoder: Encoder
    ) throws {
        var container = encoder.singleValueContainer()
        
        if let revision {
            try container.encode(
                _WithRevisionRepresentaton(
                    provider: provider,
                    name: name,
                    revision: revision
                )
            )
        } else {
            try container.encode(description)
        }
    }
}

@HadeanIdentifier("bagog-golir-jisap-mozop")
@RuntimeDiscoverable
public enum _AIModelProvider: Hashable, Sendable {
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

// MARK: - Auxiliary

extension _MLModelIdentifier {
    private enum _Anthropic_Model: String {
        case claude_v1 = "claude-v1"
        case claude_v2 = "claude-2"
        case claude_instant_v1 = "claude-instant-v1"
        
        case claude_v1_0 = "claude-v1.0"
        case claude_v1_2 = "claude-v1.2"
        case claude_v1_3 = "claude-v1.3"
        case claud_instant_v1_0 = "claude-instant-v1.0"
        case claud_instant_v1_2 = "claude-instant-v1.2"
        case claud_instant_1 = "claude-instant-1"
    }
    
    private enum _OpenAI_Model: String {
        case gpt_3_5_turbo = "gpt-3.5-turbo"
        case gpt_3_5_turbo_16k = "gpt-3.5-turbo-16k"
        case gpt_4 = "gpt-4"
        case gpt_4_32k = "gpt-4-32k"
        case gpt_4_1106_preview = "gpt-4-1106-preview"
        case gpt_4_vision_preview = "gpt-4-vision-preview"
        case gpt_3_5_turbo_0301 = "gpt-3.5-turbo-0301"
        case gpt_3_5_turbo_0613 = "gpt-3.5-turbo-0613"
        case gpt_3_5_turbo_16k_0613 = "gpt-3.5-turbo-16k-0613"
        case gpt_4_0314 = "gpt-4-0314"
        case gpt_4_0613 = "gpt-4-0613"
        case gpt_4_32k_0314 = "gpt-4-32k-0314"
        case gpt_4_32k_0613 = "gpt-4-32k-0613"
    }
}
