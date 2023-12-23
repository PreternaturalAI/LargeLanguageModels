//
// Copyright (c) Vatsal Manot
//

import CoreGML
import CorePersistence
import Swallow

public enum PromptMatterRole: Codable, Hashable, Sendable {
    public enum Text: String, CaseIterable, Codable, Hashable, Sendable {
        case prefix
    }

    public typealias Chat = AbstractLLM.ChatRole
        
    case text(Text)
    case chat(Chat)
    
    public var completionType: AbstractLLM.CompletionType {
        switch self {
            case .text:
                return .text
            case .chat:
                return .chat
        }
    }
}

extension PromptMatterRole: CaseIterable {
    public static var allCases: [Self] {
        Text.allCases.map(Self.text) + Chat.allCases.map(Self.chat)
    }
}

@HadeanIdentifier("duzod-nagiv-mokas-gilaz")
@RuntimeDiscoverable
public enum _PromptMatterRoleConstraints: Codable, Hashable, Sendable, ThrowingMergeOperatable {
    public enum _Error: Error {
        case unsupportedCompletionType
        case noClearSelection
        case badMerge
    }
    
    public var available: Set<PromptMatterRole> {
        get {
            switch self {
                case .disallowed(let set):
                    return Set(PromptMatterRole.allCases.filter({ !set.contains($0) }))
                case .allowed(let set):
                    return Set(PromptMatterRole.allCases.filter({ set.contains($0) }))
                case .selected(let element):
                    return [element]
            }
        }
    }
    
    case disallowed(Set<PromptMatterRole>)
    case allowed(Set<PromptMatterRole>)
    case selected(PromptMatterRole)
    
    public mutating func mergeInPlace(
        with other: Self
    ) throws {
        switch (self, other) {
            case (.disallowed(let lhs), .disallowed(let rhs)):
                self = .disallowed(lhs.union(rhs))
            case (.disallowed(let lhs), .allowed(let rhs)):
                let set = rhs.subtracting(lhs)
                
                if set.isEmpty {
                    throw _Error.badMerge
                } else {
                    self = .allowed(set)
                }
            case (.disallowed(let lhs), .selected(let rhs)):
                if lhs.contains(rhs) {
                    throw _Error.badMerge
                } else {
                    self = .selected(rhs)
                }
            case (.allowed(let lhs), .allowed(let rhs)):
                let set = lhs.intersection(rhs)
                
                if set.isEmpty {
                    throw _Error.badMerge
                } else {
                    self = .allowed(set)
                }
            case (.allowed(let lhs), .selected(let rhs)):
                guard lhs.contains(rhs) else {
                    throw _Error.badMerge
                }
                
                self = .selected(rhs)
            case (.selected(let lhs), .selected(let rhs)):
                guard lhs == rhs else {
                    throw _Error.badMerge
                }
                
                self = .selected(rhs)
            default:
                var new = other
                
                try new.mergeInPlace(with: self)
                
                self = new
        }
        
        switch self {
            case .allowed(let set):
                if set.isEmpty {
                    assertionFailure()
                }
                
                if set.count == 1 {
                    self = .selected(set.first!)
                }
            default:
                break
        }
    }
}

extension PromptLiteralContext {
    @RuntimeDiscoverable
    @HadeanIdentifier("bijoz-nipoh-rakuh-fudum")
    struct PromptMatterRoleKey: PromptLiteralContextKey {
        typealias Value = _PromptMatterRoleConstraints?
        
        static let defaultValue: Value = nil
    }
    
    public var role: _PromptMatterRoleConstraints? {
        get {
            self[PromptMatterRoleKey.self]
        } set {
            self[PromptMatterRoleKey.self] = newValue
        }
    }
}

extension PromptLiteralContext {
    @HadeanIdentifier("rajil-pagik-tibah-jibod")
    struct ModelIdentifierKey: PromptLiteralContextKey {
        typealias Value = _GMLModelIdentifierScope?
        
        static var defaultValue: _GMLModelIdentifierScope? = nil
    }
    
    public var modelIdentifier: _GMLModelIdentifierScope? {
        get {
            self[ModelIdentifierKey.self]
        } set {
            self[ModelIdentifierKey.self] = newValue
        }
    }
}

public struct PromptMatterRoles {
    @_spi(Private)
    public let base: _PromptMatterRoleConstraints
    
    private init(base: _PromptMatterRoleConstraints) {
        self.base = base
    }
    
    public static var all: Self {
        Self(base: .disallowed([]))
    }
    
    public static func all(except roles: PromptMatterRole...) -> Self {
        Self(base: .disallowed(.init(roles)))
    }
    
    public static var chat: PromptMatterRoles {
        Self(base: .allowed(Set(PromptMatterRole.Chat.allCases.map(PromptMatterRole.chat))))
    }
    
    public static var text: PromptMatterRoles {
        Self(base: .allowed(Set(PromptMatterRole.Text.allCases.map(PromptMatterRole.text))))
    }
}

// MARK: - Auxiliary

extension AbstractLLM.ChatRole {
    public init(from role: PromptMatterRole) throws {
        guard case .chat(let role) = role else {
            throw Never.Reason.illegal
        }
        
        self = role
    }
}
