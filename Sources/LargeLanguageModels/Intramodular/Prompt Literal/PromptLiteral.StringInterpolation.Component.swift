//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import Foundation
import Swallow

extension PromptLiteral.StringInterpolation {
    public struct Component: Hashable, Sendable {
        public var payload: Payload
        public var context: PromptLiteralContext
        
        public init(
            payload: Payload,
            context: PromptLiteralContext
        ) {
            self.payload = payload
            self.context = context
            
            if case .promptLiteralConvertible(let value) = payload {
                assert(!(value is any _opaque_DynamicPromptVariable))
            }
        }
        
        @_spi(Internal)
        public init(
            payload: Payload,
            role: PromptMatterRole? = nil
        ) {
            var context = PromptLiteralContext()
            
            if let role {
                context.role = .selected(role)
            }
            
            self.init(
                payload: payload,
                context: context
            )
        }
    }
}

extension PromptLiteral.StringInterpolation.Component {
    @usableFromInline
    static func _join(_ lhs: Self, _ rhs: Self) -> Self? {
        guard let context = try? lhs.context.merging(rhs.context) else {
            return nil
        }
        
        let payload: Payload
        
        switch (lhs.payload, rhs.payload) {
            case (.stringLiteral(let lhs), .stringLiteral(let rhs)):
                payload = .stringLiteral(lhs + rhs)
            default:
                return nil
        }
        
        return Self(payload: payload, context: context)
    }
}

// MARK: - Conformances

extension PromptLiteral.StringInterpolation.Component: CustomStringConvertible {
    public var debugDescription: String {
        payload.debugDescription
    }
    
    public var description: String {
        String(describing: payload)
    }
}

extension PromptLiteral.StringInterpolation.Component: Codable {
    private enum CodingKeys: String, CodingKey {
        case payload
        case context
    }
    
    public init(from decoder: Decoder) throws {
        do {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            self.payload = try container.decode(Payload.self, forKey: .payload)
            self.context = try container.decodeIfPresent(PromptLiteralContext.self, forKey: .context) ?? .init()
        } catch {
            if let payload = try? Payload(from: decoder) {
                self.payload = payload
                self.context = .init()
                
                runtimeIssue(.deprecated)
            } else {
                throw error
            }
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(payload, forKey: .payload)
        try container.encode(context, forKey: .context)
    }
}
