//
// Copyright (c) Vatsal Manot
//

import Swallow

public protocol LLMTokenizer<Token> {
    associatedtype Token: Hashable
    
    func encode(_ input: String) throws -> [Token]
    func decode(_ tokens: [Token]) throws -> String
}
