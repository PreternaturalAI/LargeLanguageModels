//
// Copyright (c) Vatsal Manot
//

@_exported import CorePersistence
@_exported import Merge

public enum _module {
    public static func initialize() {
        _UniversalTypeRegistry.register(TextEmbeddings.self)
        _UniversalTypeRegistry.register(TextEmbeddings.Element.self)
    }
}

extension DependencyValues {
    /// The LLMs available in this dependency context.
    public var llmServices: (any LargeLanguageModelServices)? {
        get {
            self[_OptionalDependencyKey.self]
        } set {
            self[_OptionalDependencyKey.self] = newValue
        }
    }
}

extension DependencyValues {
    public var textEmbeddingsProvider: (any TextEmbeddingsProvider)? {
        get {
            self[_OptionalDependencyKey.self]
        } set {
            self[_OptionalDependencyKey.self] = newValue
        }
    }
}
