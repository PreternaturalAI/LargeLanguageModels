//
// Copyright (c) Vatsal Manot
//

import Diagnostics
import Foundation
import Swallow

public protocol __AbstractLLM_ChatRole_Initiable {
    init(from role: AbstractLLM.ChatRole) throws
}

extension AbstractLLM {
    public typealias ChatRoleInitiable = __AbstractLLM_ChatRole_Initiable
    
    public enum ChatRole: CaseIterable, Hashable, Sendable {
        public enum Other: String, CaseIterable, CustomStringConvertible, Hashable, Sendable {
            /// The function that was just run.
            case function = "openai-function"
            
            public var description: String {
                switch self {
                    case .function:
                        return "Function"
                }
            }
        }
        
        public static var allCases: [Self] {
            [.system, .user, .assistant] + Other.allCases.map({ Self.other($0) })
        }
        
        case system
        case user
        case assistant
        case other(Other)
    }
}

// MARK: - Conformances

extension AbstractLLM.ChatRole: Codable {
    public func encode(to encoder: Encoder) throws {
        try rawValue.encode(to: encoder)
    }
    
    public init(from decoder: Decoder) throws {
        guard let role = Self(rawValue: try String(from: decoder)) else {
            throw DecodingError.dataCorrupted(.init(codingPath: []))
        }
        
        self = role
    }
}

extension AbstractLLM.ChatRole: CustomStringConvertible {
    public var description: String {
        switch self {
            case .system:
                return "System"
            case .user:
                return "User"
            case .assistant:
                return "Assistant"
            case .other(let value):
                return "Other (\(value.description))"
        }
    }
}

extension AbstractLLM.ChatRole: RawRepresentable {
    public var rawValue: String {
        switch self {
            case .system:
                return "system"
            case .user:
                return "user"
            case .assistant:
                return "assistant"
            case .other(let value):
                return value.rawValue
        }
    }
    
    public init?(rawValue: String) {
        switch rawValue {
            case Self.system.rawValue:
                self = .system
            case Self.user.rawValue:
                self = .user
            case Self.assistant.rawValue:
                self = .assistant
            case Other.function.rawValue:
                self = .other(.function)
            default:
                runtimeIssue(.unexpected)
                
                return nil
        }
    }
}
