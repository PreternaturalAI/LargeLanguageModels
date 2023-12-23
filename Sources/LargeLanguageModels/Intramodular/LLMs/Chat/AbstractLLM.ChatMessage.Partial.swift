//
// Copyright (c) Vatsal Manot
//

import Compute
import Foundation
import Swallow

extension AbstractLLM.ChatMessage {
    @frozen
    public struct Partial: Codable, CustomStringConvertible, Hashable, Initiable, Partializable, Sendable {
        @usableFromInline
        enum Attribute: Codable, Hashable, Sendable {
            @usableFromInline
            enum MessageType: Codable, Hashable, Sendable {
                case delta
                case whole
            }
            
            case messageType(MessageType)
        }
        
        public let id: AnyPersistentIdentifier?
        public let role: AbstractLLM.ChatRole?
        public let content: PromptLiteral?
        public let index: Int?
        
        @usableFromInline
        var attributes: Set<Attribute> = []
        
        public var description: String {
            content?.description ?? "<error>"
        }
        
        public init(
            id: AnyPersistentIdentifier?,
            role: AbstractLLM.ChatRole?,
            content: PromptLiteral?,
            index: Int?
        ) {
            self.id = id
            self.role = role
            self.content = content
            self.index = index
        }
        
        public init() {
            self.init(id: nil, role: nil, content: nil, index: nil)
        }
        
        public mutating func coalesceInPlace(
            with partial: Partial
        ) throws {
            do {
                if let id = self.id, let partialID = partial.id {
                    try _tryAssert(id == partialID)
                }
                
                if let role = self.role, let partialRole = partial.role {
                    try _tryAssert(role == partialRole)
                }
                
                if let index = self.index, let partialIndex = partial.index {
                    try _tryAssert(index < partialIndex)
                }
            } catch {
                throw error
            }
            
            if self.attributes.contains(.messageType(.whole)) {
                if partial.attributes.contains(.messageType(.whole)) {
                    self = partial
                    
                    return
                } else {
                    guard partial.attributes.contains(.messageType(.delta)) else {
                        throw Never.Reason.illegal
                    }
                }
            }
            
            let lhsContent: PromptLiteral = content ?? PromptLiteral.empty
            let rhsContent: PromptLiteral = partial.content ?? PromptLiteral.empty
            
            self = Self(
                id: id ?? partial.id,
                role: role ?? partial.role,
                content: lhsContent.appending(contentsOf: rhsContent),
                index: nil
            )
        }
    }
}

extension AbstractLLM.ChatMessage.Partial {
    public init(
        delta message: AbstractLLM.ChatMessage
    ) {
        self.init(
            id: message.id,
            role: message.role,
            content: message.content,
            index: nil
        )
        
        attributes.insert(Attribute.messageType(.delta))
    }
    
    public init(
        whole message: AbstractLLM.ChatMessage
    ) {
        self.init(
            id: message.id,
            role: message.role,
            content: message.content,
            index: nil
        )
        
        assert(message.id != nil)
        
        attributes.insert(Attribute.messageType(.whole))
    }
}

extension AbstractLLM.ChatMessage {
    public init(
        from partial: AbstractLLM.ChatMessage.Partial
    ) throws {
        self.init(
            id: partial.id,
            role: try partial.role.unwrap(),
            content: try partial.content.unwrap()
        )
    }
}
