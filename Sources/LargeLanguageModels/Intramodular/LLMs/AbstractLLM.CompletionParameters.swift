//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import Foundation
import Swallow

public protocol __AbstractLLM_CompletionParameters: Hashable, Sendable {
    
}

extension AbstractLLM {
    public typealias CompletionParameters = __AbstractLLM_CompletionParameters
            
    public enum TokenLimit: Hashable, Sendable {
        case max
        case fixed(Int)
        
        public var fixedValue: Int? {
            guard case .fixed(let value) = self else {
                return nil
            }
            
            return value
        }
    }
    
    public enum TemperatureOrTopP: Hashable, Sendable {
        case temperature(Double)
        case topProbabilityMass(Double)
        
        public var temperature: Double? {
            guard case .temperature(let value) = self else {
                return nil
            }
            
            return value
        }
        
        public var topProbabilityMass: Double? {
            guard case .topProbabilityMass(let value) = self else {
                return nil
            }
            
            return value
        }
    }
}
