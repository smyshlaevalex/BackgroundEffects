//
//  VariableBlurView.swift
//  AdvancedVisualEffectView
//
//  Created by Alexander Smyshlaev on 09.07.26.
//

import SwiftUI

private struct BlurSection: Identifiable, Hashable {
    let id: Int
    let radius: CGFloat
    let stops: [Gradient.Stop]
}

struct VariableBlurView: View {
    let gradientStops: [CGFloat]
    let edge: Edge
    let maxRadius: CGFloat
    
    private let minRadius: CGFloat = 0.5
    
    @State private var sections: [BlurSection] = []
    
    var body: some View {
        ZStack {
            ForEach(sections) { section in
                RawBackgroundEffectView()
                    .blur(radius: section.radius, opaque: true)
                    .mask {
                        LinearGradient(stops: section.stops, startPoint: startPoint(), endPoint: endPoint())
                    }
            }
        }
        .onChange(of: gradientStops, initial: true) { _, newValue in
            updateSections()
        }
        .onChange(of: maxRadius) { _, newValue in
            updateSections()
        }
    }
    
    private func updateSections() {
        let gradientStops = gradientStops + [1]
        sections = (0..<gradientStops.count).map { index in
            let previousPreviousSegmentHeight = index > 1 ? gradientStops[index - 2] : 0
            let previousSegmentHeight = index > 0 ? gradientStops[index - 1] : 0
            let segmentHeight = gradientStops[index]
            let nextSegmentHeight = index < (gradientStops.count - 1) ? gradientStops[index + 1] : 0
            
            let stops: [Gradient.Stop]
            if index == 0 {
                stops = [
                    .init(color: .black, location: segmentHeight),
                    .init(color: .clear, location: nextSegmentHeight)
                ]
            } else if index < gradientStops.count - 1 {
                stops = [
                    .init(color: .clear, location: previousPreviousSegmentHeight),
                    .init(color: .black, location: previousSegmentHeight),
                    .init(color: .black, location: segmentHeight),
                    .init(color: .clear, location: nextSegmentHeight)
                ]
            } else {
                stops = [
                    .init(color: .clear, location: previousPreviousSegmentHeight),
                    .init(color: .black, location: previousSegmentHeight)
                ]
            }
            
            return BlurSection(
                id: index,
                radius: index >= gradientStops.count - 1 ? minRadius : (maxRadius - minRadius) * (CGFloat(gradientStops.count - index) / CGFloat(gradientStops.count)) + minRadius,
                stops: stops
            )
        }
    }
    
    private func startPoint() -> UnitPoint {
        switch edge {
        case .top: .top
        case .leading: .leading
        case .bottom: .bottom
        case .trailing: .trailing
        }
    }
    
    private func endPoint() -> UnitPoint {
        switch edge {
        case .top: .bottom
        case .leading: .trailing
        case .bottom: .top
        case .trailing: .leading
        }
    }
}
