//
//  RawBackgroundEffectView.swift
//  AdvancedVisualEffectView
//
//  Created by Alexander Smyshlaev on 09.07.26.
//

import SwiftUI

struct RawBackgroundEffectView: View {
    var effect: UIVisualEffect = UIBlurEffect(style: .regular)
    var intensity: CGFloat = 0
    var cornerConfiguration: Any? = nil
    
    @State private var update = 0
    
    public var body: some View {
        BackgroundEffectWrapperView(effect: effect, intensity: intensity, cornerConfiguration: cornerConfiguration, update: update)
            .onAppear {
                update += 1
            }
    }
}

struct BackgroundEffectWrapperView: UIViewRepresentable {
    let effect: UIVisualEffect
    let intensity: CGFloat
    let cornerConfiguration: Any?
    let update: Int
    
    @State private var isStopped = false
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: nil)
        
        context.coordinator.animator = makeAnimator(view: view)
        
        context.coordinator.willEnterForeground = NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { [weak view] _ in
            if let view {
                DispatchQueue.main.async {
                    isStopped = true
                    view.effect = nil
                    context.coordinator.animator?.stopAnimation(true)
                    context.coordinator.animator = makeAnimator(view: view)
                }
            }
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        if #available(iOS 26.0, *) {
            if let cornerConfiguration = cornerConfiguration as? UICornerConfiguration {
                uiView.cornerConfiguration = cornerConfiguration
            }
        }
        
        if isStopped {
            DispatchQueue.main.async {
                isStopped = false
            }
            
            uiView.effect = nil
            context.coordinator.animator?.stopAnimation(true)
            context.coordinator.animator = makeAnimator(view: uiView)
        }
        
        DispatchQueue.main.async {
            context.coordinator.animator?.fractionComplete = intensity
        }
    }
    
    static func dismantleUIView(_ uiView: UIVisualEffectView, coordinator: Coordinator) {
        coordinator.animator?.stopAnimation(true)
        if let willEnterForeground = coordinator.willEnterForeground {
            NotificationCenter.default.removeObserver(willEnterForeground)
        }
    }
    
    private func makeAnimator(view: UIVisualEffectView) -> UIViewPropertyAnimator {
        let animator = UIViewPropertyAnimator(duration: 1, curve: .linear) { [weak view] in
            view?.effect = effect
        }
        animator.addCompletion { _ in
            isStopped = true
        }
        
        return animator
    }
}

extension BackgroundEffectWrapperView {
    final class Coordinator {
        var animator: UIViewPropertyAnimator?
        var willEnterForeground: NSObjectProtocol?
    }
}
