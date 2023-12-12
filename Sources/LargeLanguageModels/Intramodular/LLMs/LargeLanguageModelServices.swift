//
// Copyright (c) Vatsal Manot
//

import Compute
import CoreGML
import Merge
import Swallow

public struct _LLMServicesConcreteDemand {
    public let parameters: any AbstractLLM.CompletionParameters
    public let heuristics: AbstractLLM.CompletionHeuristics
}

public protocol LargeLanguageModelServices {
    /// The list of available LLMs.
    ///
    /// `nil` if unknown.
    var _availableLargeLanguageModels: [_GMLModelIdentifier]? { get }
    
    /// Complete a given prompt.
    func complete<Prompt: AbstractLLM.Prompt>(
        prompt: Prompt,
        parameters: Prompt.CompletionParameters,
        heuristics: AbstractLLM.CompletionHeuristics
    ) async throws -> Prompt.Completion
    
    /// Stream a completion for a given prompt.
    func completion<Prompt: AbstractLLM.Prompt>(
        for _: Prompt,
        parameters: Prompt.CompletionParameters,
        heuristics: AbstractLLM.CompletionHeuristics
    ) async throws -> AsyncStream<Prompt.Completion.Partial>
    
    func _resolved(
        for demand: _LLMServicesConcreteDemand
    ) async throws -> any ResolveLargeLanguageModelService
}

// MARK: - Implementation

extension LargeLanguageModelServices {
    public var _availableLargeLanguageModels: [_GMLModelIdentifier]? {
        runtimeIssue(.unimplemented)
        
        return nil
    }
    
    public func completion<Prompt: AbstractLLM.Prompt>(
        for prompt: Prompt,
        parameters: Prompt.CompletionParameters,
        heuristics: AbstractLLM.CompletionHeuristics
    ) async throws -> AsyncStream<Prompt.Completion.Partial> {
        fatalError(.unimplemented)
    }
    
    public func _resolved(
        for demand: _LLMServicesConcreteDemand
    ) async throws -> any ResolveLargeLanguageModelService {
        fatalError(.unimplemented)
    }
}

// MARK: - Extensions

extension LargeLanguageModelServices {
    public func complete<Prompt: AbstractLLM.Prompt>(
        prompt: Prompt,
        parameters: Prompt.CompletionParameters
    ) async throws -> Prompt.Completion {
        try await complete(
            prompt: prompt,
            parameters: parameters,
            heuristics: nil
        )
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
