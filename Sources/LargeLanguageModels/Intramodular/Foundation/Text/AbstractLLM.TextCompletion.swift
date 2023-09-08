//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

extension AbstractLLM {
    public struct TextCompletion: Completion {
        public static var _completionType: AbstractLLM.CompletionType? {
            .text
        }
        
        public let prefix: PromptLiteral
        public let text: String
        
        public init(
            prefix: PromptLiteral,
            text: String
        ) {
            self.prefix = prefix
            self.text = text
        }
        
        public var description: String {
            text.description
        }
    }
}
