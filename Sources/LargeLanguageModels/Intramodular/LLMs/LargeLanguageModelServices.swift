//
// Copyright (c) Vatsal Manot
//

import Compute
import CoreGML
import Merge
import Swallow

/// A unified interface to an LLM.
public protocol LargeLanguageModelServices {
    /// The list of available LLMs.
    ///
    /// `nil` if unknown.
    var _availableLLMs: [_GMLModelIdentifier]? { get }
    
    /// Complete a given prompt.
    func complete<Prompt: AbstractLLM.Prompt>(
        prompt: Prompt,
        parameters: Prompt.CompletionParameters,
        heuristics: AbstractLLM.CompletionHeuristics
    ) async throws -> Prompt.Completion
    
    /// Stream a completion for a given chat prompt.
    func completion(
        for prompt: AbstractLLM.ChatPrompt
    ) async throws -> AbstractLLM.ChatCompletionStream
}

// MARK: - Implementation

extension LargeLanguageModelServices {
    public var _availableLLMs: [_GMLModelIdentifier]? {
        runtimeIssue(.unimplemented)
        
        return nil
    }
    
    public func completion(
        for prompt: AbstractLLM.ChatPrompt
    ) async throws -> AbstractLLM.ChatCompletionStream {
        AbstractLLM.ChatCompletionStream {
            try await self.complete(
                prompt: prompt,
                parameters: try prompt.context.completionParameters.map({ try cast($0) }) ?? nil
            )
        }
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
