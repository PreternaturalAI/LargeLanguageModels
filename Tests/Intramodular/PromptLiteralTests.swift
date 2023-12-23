//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import LargeLanguageModels
import XCTest

final class PromptLiteralTests: XCTestCase {
    func testEncoding() throws {
        let literal = PromptLiteral("Hello, world!")
        let encoder = JSONEncoder()
        
        XCTAssertNoThrow(try encoder.encode(literal))
    }
    
    func testInvalidEncoding() throws {
        var literal = PromptLiteral("Hello, world!")
        
        literal.stringInterpolation._sharedContext.role = .allowed([.chat(.assistant)])
        
        let encoder = HadeanTopLevelCoder(coder: .json)
        
        XCTAssertNoThrow(try encoder.encode(literal))
    }
}
