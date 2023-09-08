//
// Copyright (c) Vatsal Manot
//

import Diagnostics
import Foundation
import Swallow

extension PromptLiteral {
    public enum PromptConversionError: _ErrorX {
        case roleMissing(in: PromptLiteral.StringInterpolation.Component)
        case ambiguousCompletionType
        case unknown(AnyError)
        
        public init(_catchAll error: AnyError) {
            self = .unknown(error)
        }
    }
    
    public func convertToPrompt() throws -> any AbstractLLM.Prompt {
        try _withErrorType(PromptConversionError.self) {
            try _convertToPrompt()
        }
    }
    
    private func _convertToPrompt(
        context: PromptContextValues = .current
    ) throws -> any AbstractLLM.Prompt {
        let _completionType: AbstractLLM.CompletionType
        
        if let completionType = context.completionType {
            _completionType = completionType
        } else {
            let completionTypes = try self.stringInterpolation.components
                .compactMap { component -> _PromptMatterRoleConstraints? in
                    guard let role = component.context.role else {
                        guard component._isNewlineOrWhitespace else {
                            throw PromptConversionError.roleMissing(in: component)
                        }
                        
                        return nil
                    }
                    
                    return role
                }
                .map({ Set($0.available.map({ $0.completionType })) })
                ._intersection()
            
            do {
                _completionType = try completionTypes.toCollectionOfOne().value
            } catch {
                throw PromptConversionError.ambiguousCompletionType
            }
        }
        
        switch _completionType {
            case .text:
                try self.stringInterpolation.components.forEach { component in
                    if let role = component.context.role {
                        try _tryAssert(role.role(for: _completionType).completionType == .text)
                    } else {
                        try _tryAssert(component._isNewlineOrWhitespace)
                    }
                }
                
                return AbstractLLM.TextPrompt(prefix: self)
            case .chat:
                var messages: [AbstractLLM.ChatMessage] = []
                var currentMessage: (role: AbstractLLM.ChatRole, content: PromptLiteral)?
                
                func popCurrentMessage() {
                    if let lastMessage = currentMessage {
                        messages.append(.init(role: lastMessage.role, content: lastMessage.content))
                    }
                }
                
                let noRolesGiven = self.stringInterpolation.components.contains(where: { $0.context.role != nil }) == false
                
                for component in self.stringInterpolation.components {
                    let role: AbstractLLM.ChatRole
                    
                    if let _role = try (component.context.role?.role(for: _completionType)).map({ try AbstractLLM.ChatRole(from: $0) }) {
                        role = _role
                    } else {
                        if noRolesGiven {
                            if let variable = try? (component.payload.rawValue as? (any _opaque_DynamicPromptVariable)) {
                                assert(variable._resolvedValue != nil)
                                
                                role = .assistant
                            } else {
                                role = .user
                            }
                        } else {
                            do {
                                try _tryAssert(component._isNewlineOrWhitespace)
                            } catch {
                                throw PromptConversionError.roleMissing(in: component)
                            }
                            
                            if let _role = (currentMessage?.role ?? messages.last?.role)  {
                                role = _role
                            } else {
                                throw PromptConversionError.roleMissing(in: component)
                            }
                        }
                    }
                    
                    if let lastMessage = currentMessage, lastMessage.role == role {
                        currentMessage = (role, lastMessage.content.appending(component))
                    } else {
                        popCurrentMessage()
                        
                        currentMessage = (role, PromptLiteral(stringInterpolation: .init(components: [component])))
                    }
                }
                
                popCurrentMessage()
                
                return AbstractLLM.ChatPrompt(messages: messages)._joiningMessageTypes()
        }
    }
}

extension _PromptMatterRoleConstraints {
    public func role(
        for completionType: AbstractLLM.CompletionType
    ) throws -> PromptMatterRole {
        switch self {
            case .disallowed:
                throw _Error.noClearSelection
            case .allowed(let set):
                do {
                    return try set
                        .filter({ $0.completionType == completionType })
                        .toCollectionOfOne().value
                } catch {
                    throw _Error.unsupportedCompletionType
                }
            case .selected(let value):
                guard value.completionType == completionType else {
                    throw _Error.unsupportedCompletionType
                }
                
                return value
        }
    }
}

// MARK: - Auxiliary

extension PromptLiteral {
    fileprivate var _isNewlineOrWhitespace: Bool {
        do {
            return try self._stripToText().contains(only: CharacterSet.whitespacesAndNewlines)
        } catch {
            return false
        }
    }
}

extension PromptLiteral.StringInterpolation.Component {
    fileprivate var _isNewlineOrWhitespace: Bool {
        PromptLiteral(stringInterpolation: .init(components: [self]))._isNewlineOrWhitespace
    }
}

extension AbstractLLM.ChatPrompt {
    fileprivate func _joiningMessageTypes() -> Self {
        var newMessages: [AbstractLLM.ChatMessage] = []
        
        for message in messages {
            if newMessages.last?.role == message.role {
                newMessages.mutableLast!._unsafelyAppend(other: message)
            } else {
                newMessages.append(message)
            }
        }
        
        return .init(messages: newMessages)
    }
}
