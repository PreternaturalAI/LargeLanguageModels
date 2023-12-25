//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import LargeLanguageModels
import XCTest

final class PromptLiteralTests: XCTestCase {
    func testEncoding() throws {
        let literal = PromptLiteral("Hello, World!")
        let encoder = JSONEncoder()
        
        XCTAssertNoThrow(try encoder.encode(literal))
    }
    
    func testContextEncoding() throws {
        var literal = PromptLiteral("Hello, World!")
        
        literal.stringInterpolation._sharedContext.role = .allowed([.chat(.assistant)])
        
        let coder = HadeanTopLevelCoder(coder: .json)
        
        XCTAssertNoThrow(try coder.encode(literal))
        
        let data = try coder.encode(literal)
        let decoded = try coder.decode(PromptLiteral.self, from: data)
        
        XCTAssert(literal == decoded)
    }

    func testConcatenation() throws {
        let lhs = PromptLiteral("Hello, ")
        let rhs = PromptLiteral("World!")
        
        XCTAssert((lhs + rhs) == PromptLiteral("Hello, World!"))
        
        let threeHellos = PromptLiteral.concatenate(separator: " ") {
            lhs
            lhs
            lhs
        }
        
        XCTAssert(threeHellos == PromptLiteral("Hello,  Hello,  Hello, "))
    }
}
