//
// Copyright (c) Vatsal Manot
//

@_exported import HadeanIdentifiers
@_exported import Merge

public enum _module {
    public static func initialize() {
        _UniversalTypeRegistry.register(TextEmbeddings.self)
        _UniversalTypeRegistry.register(TextEmbeddings.Element.self)
    }
}
