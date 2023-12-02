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

extension PromptLiteral.StringInterpolation {
    public var _isEmpty: Bool {
        get throws {
            let isNotEmpty = try components.contains(where: {
                try $0.payload._isEmpty != true
            })
            
            return !isNotEmpty
        }
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
    public init(from decoder: Decoder) throws {
        self.payload = try Payload(from: decoder)
        self.context = .init()
    }
    
    public func encode(to encoder: Encoder) throws {
        assert(context.isEmpty, "unimplemented")

        try payload.encode(to: encoder)
    }
}
