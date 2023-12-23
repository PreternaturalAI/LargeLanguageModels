//
// Copyright (c) Vatsal Manot
//

import CoreGML
import Swallow

extension LargeLanguageModelServices {
    public func completion(
        for messages: [AbstractLLM.ChatMessage],
        model: some _GMLModelIdentifierConvertible
    ) async throws -> AbstractLLM.ChatCompletionStream {
        let prompt = AbstractLLM.ChatPrompt(
            messages: messages,
            context: try withMutableScope(PromptContextValues()) { context in
                context.completionType = .chat
                context.modelIdentifier = try .one(model.__conversion())
            }
        )
        
        return try await completion(for: prompt)
    }
}
