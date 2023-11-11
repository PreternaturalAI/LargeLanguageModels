//
// Copyright (c) Vatsal Manot
//

import Merge
import Swallow

public protocol ResolveLargeLanguageModelService: LargeLanguageModelServices {
    associatedtype PromptTokenizerType: PromptLiteralTokenizer
    
    func complete<Prompt: AbstractLLM.Prompt>(
        prompt: Prompt,
        parameters: Prompt.CompletionParameters
    ) async throws -> Prompt.Completion
}
