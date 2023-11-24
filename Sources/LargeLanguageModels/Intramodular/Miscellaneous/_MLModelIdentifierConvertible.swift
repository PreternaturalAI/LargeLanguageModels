//
// Copyright (c) Vatsal Manot
//

import Swallow

public protocol _MLModelIdentifierConvertible {
    func __conversion() throws -> _MLModelIdentifier
}

public protocol _MLModelIdentifierRepresentable: _MLModelIdentifierConvertible {
    init(from _: _MLModelIdentifier) throws
}
