//
//  BackgroundScreenshotEffectSourceViewModifier.swift
//  BackgroundEffects
//
//  Created by Alexander Smyshlaev on 25.07.26.
//

import SwiftUI

private struct BackgroundScreenshotEffectSourceView<Content: View>: UIViewControllerRepresentable {
    let name: AnyHashable
    let preferredFrameRateRange: CAFrameRateRange
    @ViewBuilder var content: () -> Content
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIViewController(context: Context) -> UIHostingController<Content> {
        let viewController = UIHostingController(rootView: content())
        viewController.view.backgroundColor = .clear
        
        context.coordinator.name = name
        context.coordinator.viewController = viewController
        
        context.coordinator.displayLink = CADisplayLink(target: context.coordinator, selector: #selector(Coordinator.update))
        context.coordinator.displayLink.add(to: .main, forMode: .common)
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIHostingController<Content>, context: Context) {
        context.coordinator.name = name
        context.coordinator.displayLink.preferredFrameRateRange = preferredFrameRateRange
    }
    
    static func dismantleUIViewController(_ uiViewController: UIViewController, coordinator: Coordinator) {
        coordinator.displayLink.invalidate()
    }
    
    func sizeThatFits(_ proposal: ProposedViewSize, uiViewController: UIHostingController<Content>, context: Context) -> CGSize? {
        uiViewController.sizeThatFits(in: proposal.replacingUnspecifiedDimensions())
    }
}

extension BackgroundScreenshotEffectSourceView {
    @MainActor
    final class Coordinator {
        var name: AnyHashable = 0
        weak var viewController: UIViewController?
        var displayLink: CADisplayLink!
        
        @objc func update() {
            guard let rootView = viewController?.view, let window = viewController?.view.window else {
                return
            }
            
            let position = rootView.convert(CGPoint.zero, to: window)
            
            let sourceImage = UIGraphicsImageRenderer(size: window.bounds.size).image { context in
                context.cgContext.translateBy(x: position.x, y: position.y)
                rootView.drawHierarchy(in: rootView.bounds, afterScreenUpdates: false)
            }
            
            BackgroundScreenshotEffectSourceViewModel.shared.setSourceImage(sourceImage, for: name)
        }
    }
}

public extension View {
    func backgroundScreenshotEffectSource(named name: AnyHashable, preferredFrameRateRange: CAFrameRateRange = .default) -> some View {
        BackgroundScreenshotEffectSourceView(name: name, preferredFrameRateRange: preferredFrameRateRange) {
            self
        }
        .ignoresSafeArea()
    }
}
