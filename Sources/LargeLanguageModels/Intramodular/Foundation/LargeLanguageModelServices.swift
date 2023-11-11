//
// Copyright (c) Vatsal Manot
//

import Merge
import Swallow

public struct _LLMServicesConcreteDemand {
    public let parameters: any AbstractLLM.CompletionParameters
    public let heuristics: AbstractLLM.CompletionHeuristics
}

public protocol LargeLanguageModelServices {
    func complete<Prompt: AbstractLLM.Prompt>(
        prompt: Prompt,
        parameters: Prompt.CompletionParameters,
        heuristics: AbstractLLM.CompletionHeuristics
    ) async throws -> Prompt.Completion
    
    func _resolved(
        for demand: _LLMServicesConcreteDemand
    ) async throws -> any ResolveLargeLanguageModelService
}

extension LargeLanguageModelServices {
    public func _resolved(
        for demand: _LLMServicesConcreteDemand
    ) async throws -> any ResolveLargeLanguageModelService {
        fatalError(reason: .unimplemented)
    }
}

extension LargeLanguageModelServices {
    public func complete<Prompt: AbstractLLM.Prompt>(
        prompt: Prompt,
        parameters: Prompt.CompletionParameters
    ) async throws -> Prompt.Completion {
        try await complete(prompt: prompt, parameters: parameters, heuristics: nil)
    }
    
    public func complete(
        prompt: AbstractLLM.ChatOrTextPrompt,
        parameters: any AbstractLLM.CompletionParameters,
        heuristics: AbstractLLM.CompletionHeuristics
    ) async throws -> AbstractLLM.ChatOrTextCompletion {
        switch prompt {
            case .text(let prompt):
                let completion = try await complete(
                    prompt: prompt,
                    parameters: cast(parameters),
                    heuristics: heuristics
                )
                
                return .text(completion)
            case .chat(let prompt):
                let completion = try await complete(
                    prompt: prompt,
                    parameters: cast(parameters),
                    heuristics: heuristics
                )
                
                return .chat(completion)
        }
    }
    
    public func complete(
        prompt: AbstractLLM.ChatOrTextPrompt,
        parameters: any AbstractLLM.CompletionParameters
    ) async throws -> AbstractLLM.ChatOrTextCompletion {
        try await self.complete(
            prompt: prompt,
            parameters: parameters,
            heuristics: nil
        )
    }
}

// MARK: - Auxiliary

extension DependencyValues {
    public var llmServices: (any LargeLanguageModelServices)? {
        get {
            self[_OptionalDependencyKey.self]
        } set {
            self[_OptionalDependencyKey.self] = newValue
        }
    }
}
