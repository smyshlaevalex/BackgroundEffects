//
//  LiquidLensConfiguration.swift
//  AdvancedVisualEffectView
//
//  Created by Alexander Smyshlaev on 10.07.26.
//

import SwiftUI

public struct LiquidLensConfiguration {
    public var glassIntensity: CGFloat
    
    public var cutoutMaskPadding: CGFloat
    public var cutoutMaskEdgeBlurRadius: CGFloat
    
    public var tint: Color
    
    public var awakePadding: CGFloat
    public var squishFactor: CGFloat
    
    public var restingView: AnyView
    
    public init(
        glassIntensity: CGFloat = 0.7,
        cutoutMaskPadding: CGFloat = 15,
        cutoutMaskEdgeBlurRadius: CGFloat = 5,
        tint: Color = .black.opacity(0.05),
        awakePadding: CGFloat = 8,
        squishFactor: CGFloat = 0.5,
        restingView: AnyView = AnyView(Color.black.opacity(0.3))
    ) {
        self.glassIntensity = glassIntensity
        self.cutoutMaskPadding = cutoutMaskPadding
        self.cutoutMaskEdgeBlurRadius = cutoutMaskEdgeBlurRadius
        self.tint = tint
        self.awakePadding = awakePadding
        self.squishFactor = squishFactor
        self.restingView = restingView
    }
    
    public init(_ configurator: (inout LiquidLensConfiguration) -> Void) {
        self.init()
        configurator(&self)
    }
}
