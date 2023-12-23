//
// Copyright (c) Vatsal Manot
//

import Diagnostics
import Foundation
import Swallow

public protocol NaiveLLMClassifier {
    associatedtype Category: Hashable
    
    func classify(
        _ text: String,
        context: LargeLanguageModelServices
    ) async throws -> Category
}

public enum NaiveLLMClassifiers {
    public struct IsThisAQuestion: NaiveLLMClassifier {
        public init() {
            
        }
        
        public func classify(
            _ text: String,
            context: LargeLanguageModelServices
        ) async throws -> Bool {
            let prompt = """
            Consider the following text: \(text)
            Is this a question? Answer EXACTLY with Yes or No.
            Answer:
            """
            
            let completion = try await context
                .complete(
                    prompt: AbstractLLM.TextPrompt(stringLiteral: prompt),
                    parameters: .init(
                        tokenLimit: .fixed(20),
                        temperatureOrTopP: .temperature(0.5),
                        stops: ["\n"]
                    )
                )
                .text
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            guard completion == "Yes" || completion == "No" else {
                throw _AssertionFailure()
            }
            
            return completion == "Yes"
        }
    }
    
    public struct AnswerThisYesNoQuestion: NaiveLLMClassifier {
        public init() {
            
        }
        
        public func classify(
            _ text: String,
            context: LargeLanguageModelServices
        ) async throws -> Bool {
            let prompt = """
            Consider the following yes/no question: \(text)
            What is the answer? Answer EXACTLY with Yes or No.
            Answer:
            """
            
            let completion = try await context.complete(
                prompt: AbstractLLM.TextPrompt(stringLiteral: prompt),
                parameters: .init(
                    tokenLimit: .fixed(20),
                    temperatureOrTopP: .temperature(0.5),
                    stops: ["\n"]
                )
            )
                .text
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            guard completion == "Yes" || completion == "No" else {
                throw _AssertionFailure()
            }
            
            return completion == "Yes"
        }
    }
}
