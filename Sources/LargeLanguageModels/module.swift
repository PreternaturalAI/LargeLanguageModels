//
// Copyright (c) Vatsal Manot
//

@_exported import HadeanIdentifiers
@_exported import Merge

public enum _module {
    public static func initialize() {
        _UniversalTypeRegistry.register(_RawTextEmbeddingPair.self)
        _UniversalTypeRegistry.register(TextEmbeddings.self)
    }
}
