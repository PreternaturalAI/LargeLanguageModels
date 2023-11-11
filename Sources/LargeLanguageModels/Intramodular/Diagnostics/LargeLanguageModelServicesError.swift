//
// Copyright (c) Vatsal Manot
//

import Diagnostics
import Swallow

public enum LargeLanguageModelServicesError: _ErrorX {
    case unsupportedPromptType(Metatype<any AbstractLLM.Prompt.Type>)
    case _catchAll(AnyError)
    
    public static func unsupportedPromptType(_ type: any AbstractLLM.Prompt.Type) -> Self {
        .unsupportedPromptType(Metatype(type))
    }
    
    public init?(_catchAll error: AnyError) throws {
        self = ._catchAll(error)
    }
}
