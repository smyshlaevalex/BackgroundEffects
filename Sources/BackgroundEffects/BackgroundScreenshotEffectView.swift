//
//  BackdropView.swift
//  BackgroundEffects
//
//  Created by Alexander Smyshlaev on 12.07.26.
//

import SwiftUI

public struct BackgroundScreenshotEffectView<Content: View>: UIViewRepresentable {
    private let content: (Image) -> Content
    
    public init(_ content: @escaping (Image) -> Content) {
        self.content = content
    }
    
    public func makeUIView(context: Context) -> UIView {
        BackdropUIView {
            AnyView(content($0))
        }
    }
    
    public func updateUIView(_ uiView: UIView, context: Context) {
        
    }
}

private struct BackdropSwiftUIView: View {
    let id: UUID
    let viewModel: BackdropManager
    @ViewBuilder var content: (Image) -> AnyView
    
    var body: some View {
        if let image = viewModel.properties[id]?.image {
            content(Image(uiImage: image))
        }
    }
}

private struct BackdropRootView: View {
    let viewModel: BackdropManager
    
    var body: some View {
        ZStack {
            ForEach(Array(viewModel.properties.values)) { property in
                BackdropSwiftUIView(id: property.id, viewModel: viewModel, content: property.content)
                    .frame(width: property.frame.width, height: property.frame.height)
                    .position(x: property.frame.midX, y: property.frame.midY)
            }
        }
    }
}

private final class BackdropUIView: UIView {
    private let id = UUID()
    private let content: (Image) -> AnyView
    
    private var backdropManager: BackdropManager?
    
    init(content: @escaping (Image) -> AnyView) {
        self.content = content
        
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        guard let windowScene = window?.windowScene else {
            return
        }
        
        backdropManager = BackdropManager.manager(for: windowScene)
        backdropManager?.addBackdrop(id: id, view: self, content: content)
    }
}

struct BackdropProperties: Identifiable {
    let id: UUID
    var frame: CGRect
    var image: UIImage
    weak var view: UIView?
    var content: (Image) -> AnyView
}

@MainActor
@Observable
private final class BackdropManager {
    private static var managers: [UIWindowScene: BackdropManager] = [:]
    
    private let window: UIWindow
    private(set) var properties: [UUID: BackdropProperties] = [:]
    
    private var displayLink: CADisplayLink!
    
    static func manager(for windowScene: UIWindowScene) -> BackdropManager {
        if let manager = managers[windowScene] {
            return manager
        } else {
            let manager = BackdropManager(windowScene: windowScene)
            managers[windowScene] = manager
            return manager
        }
    }
    
    init(windowScene: UIWindowScene) {
        window = UIWindow(windowScene: windowScene)
        window.rootViewController = UIHostingController(rootView: BackdropRootView(viewModel: self)
            .ignoresSafeArea())
        window.rootViewController?.view.backgroundColor = .clear
        window.windowLevel = .statusBar
        window.isUserInteractionEnabled = false
        
        let keyWindow = windowScene.keyWindow
        
        window.makeKeyAndVisible()
        
        keyWindow?.makeKey()
        
        displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink.add(to: .main, forMode: .common)
    }
    
    deinit {
        DispatchQueue.main.async {
            self.displayLink.invalidate()
            self.displayLink = nil
        }
    }
    
    func addBackdrop(id: UUID, view: UIView, content: @escaping (Image) -> AnyView) {
        properties[id] = BackdropProperties(id: id, frame: .zero, image: UIImage(), view: view, content: content)
    }
    
    func updateBackdrop(id: UUID, image: UIImage) {
        properties[id]?.image = image
    }
    
    func layoutBackdrop(id: UUID, frame: CGRect) {
        properties[id]?.frame = frame
    }
    
    func removeBackdrop(id: UUID) {
        properties[id] = nil
    }
    
    @objc private func update() {
        guard let rootView = window.windowScene?.keyWindow else {
            return
        }
        
        let windowImage = UIGraphicsImageRenderer(size: rootView.bounds.size).image { context in
            rootView.drawHierarchy(in: rootView.bounds, afterScreenUpdates: false)
        }
        
        for (id, property) in properties {
            guard let view = property.view else {
                return
            }
            
            let globalPosition = view.convert(view.bounds.origin, to: rootView)
            let frame = CGRect(origin: globalPosition, size: view.bounds.size)
            
            properties[id]?.frame = frame
            
            properties[id]?.image = UIGraphicsImageRenderer(size: frame.size).image { context in
                context.cgContext.translateBy(x: -frame.origin.x, y: -frame.origin.y)
                windowImage.draw(at: .zero)
            }
        }
    }
}

extension UIView {
    func findRootView() -> UIView {
        superview?.findRootView() ?? self
    }
}
