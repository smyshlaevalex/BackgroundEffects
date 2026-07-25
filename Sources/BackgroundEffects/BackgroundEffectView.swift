//
//  BackgroundEffectView.swift
//  BackgroundEffects
//
//  Created by Alexander Smyshlaev on 11.07.26.
//

import SwiftUI

public struct BackgroundEffectView: View {
    let effect: BackgroundEffect
    
    public init(_ effect: BackgroundEffect) {
        self.effect = effect
    }
    
    public var body: some View {
        switch effect {
        case _ as BackgroundBackdropEffect:
            RawBackgroundEffectView()
        
        case let materialEffect as BackgroundMaterialEffect:
            RawBackgroundEffectView(effect: UIBlurEffect(style: materialEffect.style), intensity: materialEffect.intensity)
            
        case let blurEffect as BackgroundBlurEffect:
            RawBackgroundEffectView(effect: UIBlurEffect(style: .regular), intensity: 0)
                .blur(radius: blurEffect.radius, opaque: blurEffect.opaque)
            
        case let variableBlurEffect as BackgroundVariableBlurEffect:
            VariableBlurView(gradientStops: variableBlurEffect.gradientStops, edge: variableBlurEffect.edge, maxRadius: variableBlurEffect.radius)
            
        default:
            if #available(iOS 26.0, *) {
                switch effect {
                case let glassEffect as BackgroundGlassEffect:
                    RawBackgroundEffectView(effect: glass(from: glassEffect), intensity: glassEffect.intensity, cornerConfiguration: glassEffect.corners)
                    
                case let lensEffect as BackgroundLensEffect:
                    LiquidLensView(configuration: lensEffect.configuration, isResting: lensEffect.isResting)
                    
                default:
                    EmptyView()
                }
            }
        }
    }
    
    @available(iOS 26.0, *)
    private func glass(from glassEffect: BackgroundGlassEffect) -> UIGlassEffect {
        let glass = UIGlassEffect(style: glassEffect.style)
        glass.tintColor = glassEffect.tint.flatMap(UIColor.init)
        glass.isInteractive = glassEffect.isInteractive
        
        return glass
    }
}

public extension View {
    func backgroundEffect(_ effect: BackgroundEffect) -> some View {
        background {
            BackgroundEffectView(effect)
        }
    }
}
