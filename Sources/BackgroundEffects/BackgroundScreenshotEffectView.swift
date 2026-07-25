//
//  BackdropView.swift
//  BackgroundEffects
//
//  Created by Alexander Smyshlaev on 12.07.26.
//

import SwiftUI

public struct BackgroundScreenshotEffectView: View {
    private let viewModel = BackgroundScreenshotEffectSourceViewModel.shared
    
    private let sourceName: AnyHashable
    
    public init(sourceName: AnyHashable) {
        self.sourceName = sourceName
    }
    
    public var body: some View {
        GeometryReader { proxy in
            if let backdropImage = viewModel.backdropImage(for: proxy.frame(in: .global), from: sourceName) {
                Image(uiImage: backdropImage)
            }
        }
    }
}

public extension View {
    func backgroundScreenshotEffect(sourceName: AnyHashable) -> some View {
        background {
            BackgroundScreenshotEffectView(sourceName: sourceName)
        }
    }
}
