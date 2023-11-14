//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import Foundation
import Swallow

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
