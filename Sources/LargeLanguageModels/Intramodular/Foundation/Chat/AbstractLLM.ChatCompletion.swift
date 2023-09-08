//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

extension AbstractLLM {
    public struct ChatCompletion: Completion {
        public static var _completionType: AbstractLLM.CompletionType? {
            .chat
        }

        public let message: AbstractLLM.ChatMessage
        
        public init(message: AbstractLLM.ChatMessage) {
            self.message = message
        }
        
        public var debugDescription: String {
            message.debugDescription
        }
    }
}
