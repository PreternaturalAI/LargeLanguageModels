//
// Copyright (c) Vatsal Manot
//

import Diagnostics
import Swallow

public enum PromptLiteralError: Error {
    case failedToReduceToPrompt(for: AbstractLLM.CompletionType?)
}
