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
                
        public init(payload: Payload, context: PromptLiteralContext) {
            self.payload = payload
            self.context = context
            
            if case .promptLiteralConvertible(let value) = payload {
                assert(!(value is any _opaque_DynamicPromptVariable))
            }
        }
    }
}

// MARK: - Conformances

extension PromptLiteral.StringInterpolation.Component: CustomStringConvertible {
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
