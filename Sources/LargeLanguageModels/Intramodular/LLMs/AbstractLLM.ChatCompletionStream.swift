//
// Copyright (c) Vatsal Manot
//

import Merge
import Swallow

public protocol __AbstractLLM_ChatCompletionStreamProtocol: ObservableObject, Publisher where Self.Output == AbstractLLM.ChatCompletionStream.Event, Failure == Error {
    typealias Event = AbstractLLM.ChatCompletionStream.Event
    typealias State = AbstractLLM.ChatCompletionStream.State
    
    var message: AbstractLLM.ChatMessage? { get }
    var messagePublisher: AnyPublisher<AbstractLLM.ChatMessage, Error> { get }
    var state: State { get }
}

extension AbstractLLM {
    public typealias ChatCompletionStreamProtocol = __AbstractLLM_ChatCompletionStreamProtocol
    
    public final class ChatCompletionStream: __AbstractLLM_ChatCompletionStreamProtocol, ObservableObject {
        public enum Event: Codable, Hashable, Sendable {
            public enum _Comparison {
                case completion
                case stop
                
                public static func == (lhs: Event, rhs: _Comparison) -> Bool {
                    switch (lhs, rhs) {
                        case (.completion, .completion):
                            return true
                        case (.stop, .stop):
                            return true
                        default:
                            return false
                    }
                }
                
                public static func == (lhs: _Comparison, rhs: Event) -> Bool {
                    rhs == lhs
                }
            }
            
            case completion(AbstractLLM.ChatCompletion.Partial)
            case stop
        }
        
        public enum State: Hashable, Sendable {
            case waiting
            case streaming
            case canceled
            case completed
            case failed(AnyError)
        }
        
        private var objectWillChangeRelay: ObjectWillChangePublisherRelay<any ChatCompletionStreamProtocol, ChatCompletionStream>!
        private let base: any ChatCompletionStreamProtocol
        
        public var message: AbstractLLM.ChatMessage? {
            base.message
        }
        
        public var messagePublisher: AnyPublisher<AbstractLLM.ChatMessage, Error> {
            base.messagePublisher
        }
        
        public var state: State {
            base.state
        }
        
        public init(base: any ChatCompletionStreamProtocol) {
            self.base = base
            
            self.objectWillChangeRelay = .init(source: base, destination: self)
        }
        
        public convenience init(
            _ stream: @escaping () async throws -> AsyncThrowingStream<AbstractLLM.ChatCompletionStream.Event, Error>
        ) {
            self.init(base: _AsyncStreamToChatCompletionStreamAdaptor(base: stream))
        }
        
        public convenience init(
            completion: @escaping () async throws -> AbstractLLM.ChatCompletion
        ) {
            self.init {
                AsyncThrowingStream.just {
                    try await Event.completion(.init(whole: completion()))
                }
            }
        }

        public func receive<S: Subscriber<Event, Error>>(
            subscriber: S
        ) {
            base.receive(subscriber: subscriber)
        }
    }
}

extension AbstractLLM {
    public final class _AsyncStreamToChatCompletionStreamAdaptor: __AbstractLLM_ChatCompletionStreamProtocol {
        private let subject = PassthroughSubject<Event, Swift.Error>()
        private let makeBase: () async throws -> AsyncThrowingStream<AbstractLLM.ChatCompletionStream.Event, Error>
        
        private var base: AsyncThrowingStream<AbstractLLM.ChatCompletionStream.Event, Error>?
        
        private let _messageSubject = PassthroughSubject<AbstractLLM.ChatMessage, Error>()
        
        @Published private var _message: AbstractLLM.ChatMessage?
        @Published private var _state: State = .waiting
        
        var currentMessage: AbstractLLM.ChatMessage.Partial?
        var stopReason: AbstractLLM.ChatCompletion.StopReason?
        
        public var message: AbstractLLM.ChatMessage? {
            _message
        }
        
        public var messagePublisher: AnyPublisher<AbstractLLM.ChatMessage, Error> {
            _messageSubject
                .onSubscribe { [weak self] in
                    self?._start()
                }
                .eraseToAnyPublisher()
        }
        
        public var state: State {
            _state
        }
        
        public init(
            base: @escaping () async throws -> AsyncThrowingStream<AbstractLLM.ChatCompletionStream.Event, Error>
        ) {
            self.makeBase = base
        }
        
        private func _start() {
            Task {
                guard self.base == nil else {
                    return
                }
                
                let stream = try await makeBase()
                
                self.base = stream
                
                try await self._subscribeAndRelay(to: stream)
            }
            ._expectNoThrow()
        }
        
        @discardableResult
        private func _subscribeAndRelay(
            to base: AsyncThrowingStream<AbstractLLM.ChatCompletionStream.Event, Error>
        ) async throws -> Bool {
            _state = .streaming
            
            do {
                for try await event in base {
                    try await _receive(event: event)
                }
                
                if stopReason == nil {
                    _setCompleted()
                    
                    subject.send(.stop)
                }
            } catch {
                _state = .failed(AnyError(erasing: error))
            }
            
            return true
        }
        
        func _setCompleted() {
            if stopReason != nil {
                assert(_state != .completed)
            }
            
            _state = .completed
        }
        
        @MainActor
        private func _receive(
            event: AbstractLLM.ChatCompletionStream.Event
        ) throws {
            switch event {
                case .completion(let completion):
                    if let partial = try AbstractLLM.ChatMessage.Partial.coalesce([currentMessage, completion.message]) {
                        var message = try AbstractLLM.ChatMessage(from: partial)
                        
                        if message.id == nil {
                            message.id = .init(erasing: UUID())
                        }
                        
                        self._message = message
                        
                        currentMessage = AbstractLLM.ChatMessage.Partial(whole: message)
                        
                        _messageSubject.send(message)
                    } else {
                        assert(self._message == nil && completion.message == nil)
                    }
                    
                    stopReason = completion.stopReason
                    
                    subject.send(event)
                case .stop:
                    _setCompleted()
                    
                    subject.send(.stop)
            }
        }
        
        public func receive<S: Subscriber<Event, Error>>(
            subscriber: S
        ) {
            guard base == nil else {
                assertionFailure()
                
                return
            }
            
            subject
                .prefixUntil(after: { $0 == .stop })
                .receive(subscriber: subscriber)
            
            _start()
        }
    }
}
