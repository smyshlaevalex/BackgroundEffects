//
//  SimpleVariableBlurView.swift
//  BackgroundEffects
//
//  Created by Alexander Smyshlaev on 08.08.26.
//

import SwiftUI

@available(iOS 26.0, *)
struct SimpleVariableBlurView: View {
    let edge: Edge
    
    private var edgeSet: Edge.Set {
        switch edge {
        case .top: .top
        case .leading: .leading
        case .bottom: .bottom
        case .trailing: .trailing
        }
    }
    
    private var alignment: Alignment {
        switch edge {
        case .top: .top
        case .leading: .leading
        case .bottom: .bottom
        case .trailing: .trailing
        }
    }
    
    private var isVertical: Bool {
        switch edge {
        case .top, .bottom: true
        case .leading, .trailing: false
        }
    }
    
    var body: some View {
        GeometryReader { proxy in
            Color.red
                .opacity(0)
                .frame(width: proxy.size.width * (isVertical ? 1 : (proxy.size.width / 20)), height: proxy.size.height * (isVertical ? (proxy.size.height / 20) : 1))
                .backgroundExtensionEffect()
                .safeAreaPadding(edgeSet, isVertical ? proxy.size.height : proxy.size.width)
                .frame(width: proxy.size.width, height: proxy.size.height, alignment: alignment)
        }
    }
}
