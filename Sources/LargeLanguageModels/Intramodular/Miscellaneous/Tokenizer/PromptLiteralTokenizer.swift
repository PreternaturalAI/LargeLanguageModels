//
// Copyright (c) Vatsal Manot
//

import Swallow

/// A tokenizer for prompt matter.
///
/// The reason this exists along with `TextTokenizer` from `Cataphyl` is because `PromptLiteral` is future-proofed for multimodal prompt matter.
public protocol PromptLiteralTokenizer<Token> {
    associatedtype Token: Hashable
    associatedtype Output: Collection where Output.Element == Token
    
    func encode(_ input: PromptLiteral) throws -> Output
    func decode(_ tokens: Output) throws -> PromptLiteral
}
