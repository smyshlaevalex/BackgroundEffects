//
//  RawBackgroundEffectView.swift
//  AdvancedVisualEffectView
//
//  Created by Alexander Smyshlaev on 09.07.26.
//

import SwiftUI

final class StaticAnimationDriver: Hashable {
    var fractionComplete: CGFloat
    
    init(fractionComplete: CGFloat) {
        self.fractionComplete = fractionComplete
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(fractionComplete)
    }
    
    static func == (lhs: StaticAnimationDriver, rhs: StaticAnimationDriver) -> Bool {
        lhs.fractionComplete == rhs.fractionComplete
    }
}

struct StaticAnimation: CustomAnimation {
    let driver: StaticAnimationDriver
    
    nonisolated func animate<V>(value: V, time: TimeInterval, context: inout AnimationContext<V>) -> V? where V : VectorArithmetic {
        value.scaled(by: driver.fractionComplete)
    }
}

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
        
        restartAnimation(view: view, driver: context.coordinator.driver)
        
        context.coordinator.willEnterForeground = NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { [weak view] _ in
            if let view {
                DispatchQueue.main.async {
                    isStopped = true
                    view.effect = nil
                    restartAnimation(view: view, driver: context.coordinator.driver)
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
            restartAnimation(view: uiView, driver: context.coordinator.driver)
        }
        
        context.coordinator.driver.fractionComplete = intensity
    }
    
    static func dismantleUIView(_ uiView: UIVisualEffectView, coordinator: Coordinator) {
        if let willEnterForeground = coordinator.willEnterForeground {
            NotificationCenter.default.removeObserver(willEnterForeground)
        }
    }
    
    private func restartAnimation(view: UIVisualEffectView, driver: StaticAnimationDriver) {
        DispatchQueue.main.async {
            UIView.animate(Animation(StaticAnimation(driver: driver))) {
                view.effect = effect
            } completion: {
                isStopped = true
            }
        }
    }
}

extension BackgroundEffectWrapperView {
    final class Coordinator {
        let driver = StaticAnimationDriver(fractionComplete: 0)
        var willEnterForeground: NSObjectProtocol?
    }
}
