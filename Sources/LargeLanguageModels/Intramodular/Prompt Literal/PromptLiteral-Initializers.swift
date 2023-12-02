//
// Copyright (c) Vatsal Manot
//

@_spi(Internal) import SwiftUIX

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS)
extension PromptLiteral {
    /// Initializes a `PromptLiteral` from an image.
    ///
    /// The image is encoded as an inline Base64 string URL.
    public init(
        image: AppKitOrUIKitImage
    ) throws {
        let base64String = try image
            .data(using: .jpeg(compressionQuality: 1.0))
            .unwrap()
            .base64EncodedString()
        
        let url = URL(string: "data:image/jpeg;base64,\(base64String)")!
        
        self.init(
            stringInterpolation: .init(
                components: [
                    PromptLiteral.StringInterpolation.Component(
                        payload: .image(.url(url)),
                        context: .init()
                    )
                ]
            )
        )
        
        if _isDebugAssertConfiguration {
            let isEmpty = try self.isEmpty
            
            assert(!isEmpty)
        }
    }
}
#endif
