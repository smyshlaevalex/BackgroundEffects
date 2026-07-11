//
//  LiquidLensView.swift
//  AdvancedVisualEffectView
//
//  Created by Alexander Smyshlaev on 09.07.26.
//

import SwiftUI

@available(iOS 26.0, *)
struct LiquidLensView: View {
    let configuration: LiquidLensConfiguration
    let isResting: Bool
    
    @State private var previousPosition: CGPoint = .zero
    @State private var squish: CGFloat = 0 // 0 - normal, 1 - squished vertically, -1 - squished horizontally
    
    var body: some View {
        GeometryReader { proxy in
            TimelineView(.animation) { context in
                ZStack {
                    RawBackgroundEffectView(effect: UIGlassEffect(style: .clear), intensity: configuration.glassIntensity, cornerConfiguration: UICornerConfiguration.capsule())
                }
                .mask {
                    ZStack {
                        Capsule()
                        Capsule()
                            .blur(radius: isResting ? 0 : configuration.cutoutMaskEdgeBlurRadius)
                            .padding(isResting ? 0 : configuration.cutoutMaskPadding)
                            .blendMode(.destinationOut)
                    }
                    .compositingGroup()
                }
                .background {
                    Capsule()
                        .fill(configuration.tint)
                }
                .overlay {
                    configuration.restingView
                        .clipShape(Capsule())
                        .opacity(isResting ? 1 : 0)
                }
                .padding(isResting ? 0 : -configuration.awakePadding)
                .scaleEffect(x: 1 + (configuration.squishFactor * squish), y: 1 - (configuration.squishFactor * squish))
                .animation(.bouncy, value: squish)
                .animation(.bouncy, value: isResting)
                .onChange(of: context.date) {
                    let frame = proxy.frame(in: .global)
                    let position = CGPoint(x: frame.midX, y: frame.midY)
                    
                    let distance = sqrt((previousPosition.x - position.x) * (previousPosition.x - position.x) + (previousPosition.y - position.y) * (previousPosition.y - position.y))
                    squish = distance / 20
                    
                    if position.x < previousPosition.x {
                        squish = -squish
                    }
                    
                    previousPosition = position
                }
            }
        }
    }
}
