//
//  BackgroundEffect.swift
//  BackgroundEffects
//
//  Created by Alexander Smyshlaev on 11.07.26.
//

import SwiftUI

public protocol BackgroundEffect {}

public struct BackgroundBackdropEffect: BackgroundEffect {}

public struct BackgroundMaterialEffect: BackgroundEffect {
    let style: UIBlurEffect.Style
    let intensity: CGFloat
}

@available(iOS 26.0, *)
public struct BackgroundGlassEffect: BackgroundEffect {
    let style: UIGlassEffect.Style
    let tint: Color?
    let isInteractive: Bool
    let corners: UICornerConfiguration
    let intensity: CGFloat
}

public struct BackgroundBlurEffect: BackgroundEffect {
    let radius: CGFloat
    let opaque: Bool
}

@available(iOS 26.0, *)
public struct BackgroundSimpleVariableBlurEffect: BackgroundEffect {
    let edge: Edge
}

public struct BackgroundVariableBlurEffect: BackgroundEffect {
    let radius: CGFloat
    let edge: Edge
    let gradientStops: [CGFloat]
}

@available(iOS 26.0, *)
public struct BackgroundLensEffect: BackgroundEffect {
    let configuration: LiquidLensConfiguration
    let isResting: Bool
}

public extension BackgroundEffect where Self == BackgroundBackdropEffect {
    static var backdrop: BackgroundBackdropEffect {
        BackgroundBackdropEffect()
    }
}

public extension BackgroundEffect where Self == BackgroundMaterialEffect {
    static func material(style: UIBlurEffect.Style, intensity: CGFloat = 1) -> BackgroundMaterialEffect {
        BackgroundMaterialEffect(style: style, intensity: intensity)
    }
}

@available(iOS 26.0, *)
public extension BackgroundEffect where Self == BackgroundGlassEffect {
    static func glass(
        style: UIGlassEffect.Style,
        tint: Color? = nil,
        isInteractive: Bool = false,
        corners: UICornerConfiguration = .capsule(),
        intensity: CGFloat = 1
    ) -> BackgroundGlassEffect {
        BackgroundGlassEffect(style: style, tint: tint, isInteractive: isInteractive, corners: corners, intensity: intensity)
    }
}

public extension BackgroundEffect where Self == BackgroundBlurEffect {
    static func blur(radius: CGFloat, opaque: Bool = false) -> BackgroundBlurEffect {
        BackgroundBlurEffect(radius: radius, opaque: opaque)
    }
}

@available(iOS 26.0, *)
public extension BackgroundEffect where Self == BackgroundSimpleVariableBlurEffect {
    static func simpleVariableBlur(edge: Edge = .top) -> BackgroundSimpleVariableBlurEffect {
        BackgroundSimpleVariableBlurEffect(edge: edge)
    }
}

public extension BackgroundEffect where Self == BackgroundVariableBlurEffect {
    static func variableBlur(radius: CGFloat, edge: Edge = .top, segments: Int = 10) -> BackgroundVariableBlurEffect {
        BackgroundVariableBlurEffect(
            radius: radius,
            edge: edge,
            gradientStops: (1..<segments).map {
                1 / CGFloat(segments) * CGFloat($0)
            }
        )
    }
    
    static func variableBlur(radius: CGFloat, edge: Edge = .top, gradientStops: [CGFloat]) -> BackgroundVariableBlurEffect {
        BackgroundVariableBlurEffect(radius: radius, edge: edge, gradientStops: gradientStops)
    }
}

@available(iOS 26.0, *)
public extension BackgroundEffect where Self == BackgroundLensEffect {
    static func lens(configuration: LiquidLensConfiguration = LiquidLensConfiguration(), isResting: Bool) -> BackgroundLensEffect {
        BackgroundLensEffect(configuration: configuration, isResting: isResting)
    }
}
