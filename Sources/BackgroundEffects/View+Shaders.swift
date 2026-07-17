//
//  View+Shaders.swift
//  BackgroundEffects
//
//  Created by Alexander Smyshlaev on 15.07.26.
//

import SwiftUI

public extension View {
    func pixellate(strength: CGFloat) -> some View {
        layerEffect(ShaderLibrary.bundle(.module).pixellate(.float(strength)), maxSampleOffset: .zero)
    }
    
    func wave(time: TimeInterval, intensity: CGFloat) -> some View {
        distortionEffect(ShaderLibrary.bundle(.module).wave(.float(time), .float(intensity)), maxSampleOffset: .zero)
    }
}
