//
// Copyright (c) Vatsal Manot
//

import Swallow

public protocol _opaque_DynamicPromptVariable: PromptLiteralConvertible {
    associatedtype ResolvedValue
    
    var _resolvedValue: ResolvedValue? { get }
}
