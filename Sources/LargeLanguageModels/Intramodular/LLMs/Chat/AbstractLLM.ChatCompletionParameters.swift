//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import Foundation
import Swallow

extension AbstractLLM {
    public struct ChatFunctionDefinition: Codable, Hashable, Sendable {
        public let name: String
        public let context: String
        public let parameters: JSONSchema
        
        public init(
            name: String,
            context: String,
            parameters: JSONSchema
        ) {
            self.name = name
            self.context = context
            self.parameters = parameters
        }
    }
    
    public struct ChatCompletionParameters: CompletionParameters {
        public let tokenLimit: TokenLimit?
        public let temperatureOrTopP: TemperatureOrTopP?
        public let stops: [String]?
        public let functions: [ChatFunctionDefinition]?
        
        public init(
            tokenLimit: AbstractLLM.TokenLimit? = nil,
            temperatureOrTopP: AbstractLLM.TemperatureOrTopP? = nil,
            stops: [String]? = nil,
            functions: [ChatFunctionDefinition]? = nil
        ) {
            self.tokenLimit = tokenLimit
            self.temperatureOrTopP = temperatureOrTopP
            self.stops = stops
            self.functions = functions
        }
    }
}

// MARK: - Conformances

extension AbstractLLM.ChatCompletionParameters: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self.init(tokenLimit: nil, temperatureOrTopP: nil, stops: nil, functions: nil)
    }
}
