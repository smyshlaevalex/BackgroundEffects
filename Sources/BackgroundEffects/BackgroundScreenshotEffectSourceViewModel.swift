//
//  BackgroundScreenshotEffectSourceViewModel.swift
//  BackgroundEffects
//
//  Created by Alexander Smyshlaev on 25.07.26.
//

import SwiftUI

@Observable
final class BackgroundScreenshotEffectSourceViewModel {
    @MainActor static let shared = BackgroundScreenshotEffectSourceViewModel()
    
    private init() {}
    
    private(set) var sourceImages: [AnyHashable: UIImage] = [:]
    
    func setSourceImage(_ sourceImage: UIImage, for sourceName: AnyHashable) {
        sourceImages[sourceName] = sourceImage
    }
    
    func backdropImage(for rect: CGRect, from sourceName: AnyHashable) -> UIImage? {
        guard let sourceImage = sourceImages[sourceName] else {
            return nil
        }
        
        return UIGraphicsImageRenderer(size: rect.size).image { context in
            context.cgContext.translateBy(x: -rect.origin.x, y: -rect.origin.y)
            sourceImage.draw(at: .zero)
        }
    }
}
