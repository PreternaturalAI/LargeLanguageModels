//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

extension AbstractLLM {
    public enum QualitativeAttribute: Hashable {
        case reasoning
        case conciseness
        case speed
    }
    
    public enum InferenceHeuristicFlag: Hashable {
        case maximize(Set<QualitativeAttribute>)
        
        public static func maximize(_ attributes: QualitativeAttribute...) -> Self {
            .maximize(Set(attributes))
        }
        
        public var _maximizeValue: Set<QualitativeAttribute>? {
            guard case .maximize(let value) = self else {
                return nil
            }
            
            return value
        }
    }
}

extension AbstractLLM {
    public struct CompletionHeuristics: ExpressibleByNilLiteral {
        public var inference: [InferenceHeuristicFlag] = [.maximize(.reasoning)]
        
        public init(
            inference: InferenceHeuristicFlag...
        ) {
            self.inference = inference
        }
        
        public init(nilLiteral: ()) {
            
        }
    }
}

extension AbstractLLM.CompletionHeuristics {
    public var wantsMaximumReasoning: Bool {
        inference.contains(
            where: { $0._maximizeValue.flatMap({ $0.contains(.reasoning) }) ?? false }
        )
    }
}
