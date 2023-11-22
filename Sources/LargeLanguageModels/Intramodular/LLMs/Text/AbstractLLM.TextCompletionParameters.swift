//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

extension AbstractLLM {
    public struct TextCompletionParameters: CompletionParameters {
        public let tokenLimit: TokenLimit
        public let temperatureOrTopP: TemperatureOrTopP?
        public let stops: [String]?
        
        public init(
            tokenLimit: AbstractLLM.TokenLimit,
            temperatureOrTopP: AbstractLLM.TemperatureOrTopP? = nil,
            stops: [String]? = nil
        ) {
            self.tokenLimit = tokenLimit
            self.temperatureOrTopP = temperatureOrTopP
            self.stops = stops
        }
        
        public init(nilLiteral: ()) {
            self.init(tokenLimit: .max, temperatureOrTopP: nil, stops: nil)
        }
    }
}
