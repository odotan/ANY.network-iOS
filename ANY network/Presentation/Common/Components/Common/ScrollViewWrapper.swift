import SwiftUI

public struct ScrollViewWrapper<Content: View>: UIViewRepresentable {
    @Binding var contentOffset: CGPoint
    @Binding var contentSize: CGSize
    @Binding var size: CGSize
    @Binding var zoomScale: CGFloat
    @State var userInteracting: Bool = false
    
    var contentIdentifier: UUID

    let animationDuration: CGFloat
    var scrollEnabled: Bool = false
    let minZoomLevel: CGFloat
    let maxZoomLevel: CGFloat
    let content: () -> Content
    
    public init(
        contentOffset: Binding<CGPoint>,
        contentSize: Binding<CGSize>,
        size: Binding<CGSize>,
        zoomScale: Binding<CGFloat>,
        scrollEnabled: Bool = true,
        animationDuration: CGFloat = 0.35,
        minZoomLevel: CGFloat = 1,
        maxZoomLevel: CGFloat = 10,
        contentId: UUID,
        @ViewBuilder _ content: @escaping () -> Content) {
            self._contentOffset = contentOffset
            self._contentSize = contentSize
            self._size = size
            self._zoomScale = zoomScale
            self.scrollEnabled = scrollEnabled
            self.animationDuration = animationDuration
            self.minZoomLevel = minZoomLevel
            self.maxZoomLevel = maxZoomLevel
            self.contentIdentifier = contentId
            self.content = content
        }
    
    public func makeUIView(context: UIViewRepresentableContext<ScrollViewWrapper>) -> UIScrollView {
        let view = UIScrollView()
        view.delegate = context.coordinator
        view.minimumZoomScale = minZoomLevel
        view.maximumZoomScale = maxZoomLevel
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.isScrollEnabled = scrollEnabled
        
        // Instantiate the UIHostingController with the SwiftUI view
        let controller = UIHostingController(rootView: content())
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controller.view)
        
        controller.view.sizeToFit()
        view.contentSize = controller.view.bounds.size
        
        context.coordinator.hostingController = controller
        context.coordinator.scrollView = view
        
        // Add double-tap gesture recognizer
        let doubleTap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTap)
        
        return view
    }
    
    public func updateUIView(_ uiView: UIScrollView, context: UIViewRepresentableContext<ScrollViewWrapper>) {
        let newContent = content()
        
        uiView.isScrollEnabled = scrollEnabled

        if context.coordinator.contentIdentifier != contentIdentifier {
            DispatchQueue.main.async {
                context.coordinator.hostingController.rootView = newContent
                context.coordinator.hostingController.view.sizeToFit()
                uiView.contentSize = context.coordinator.hostingController.view.frame.size
                context.coordinator.contentIdentifier = contentIdentifier
                context.coordinator.centerContent()
            }
        }
        
        if (uiView.contentOffset != contentOffset || uiView.zoomScale != self.zoomScale) && !userInteracting {
            UIView.animate(withDuration: animationDuration) {
                uiView.contentOffset = self.contentOffset
                uiView.zoomScale = self.zoomScale
                context.coordinator.centerContent()
            }
        }
        
        if contentSize != uiView.contentSize || size != uiView.frame.size {
            DispatchQueue.main.async {
                self.contentSize = uiView.contentSize
                self.size = uiView.frame.size
                
                if let hostedView = uiView.subviews.first {
                    hostedView.frame = CGRect(origin: .zero, size: uiView.contentSize)
                }
                context.coordinator.centerContent()
            }
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(contentOffset: self._contentOffset, zoomScale: self._zoomScale, contentIdentifier: contentIdentifier, userInteracting: $userInteracting)
    }
    
    public class Coordinator: NSObject, UIScrollViewDelegate {
        let contentOffset: Binding<CGPoint>
        let zoomScale: Binding<CGFloat>
        
        var hostingController: UIHostingController<Content>!
        var contentIdentifier: UUID?
        weak var scrollView: UIScrollView?

        var userInteracting: Binding<Bool>
    
        init(contentOffset: Binding<CGPoint>, zoomScale: Binding<CGFloat>, contentIdentifier: UUID?, userInteracting: Binding<Bool>) {
            self.contentOffset = contentOffset
            self.zoomScale = zoomScale
            self.contentIdentifier = contentIdentifier
            self.userInteracting = userInteracting
        }
        
        // Remove centerContent logic (no contentInset)
        func centerContent() {
            // Do nothing (removes padding)
        }
        
        // Add double-tap handler
        @objc func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
            guard let scrollView = gesture.view as? UIScrollView else { return }
            let pointInView = gesture.location(in: scrollView.subviews.first)
            let maxZoom = scrollView.maximumZoomScale
            let minZoom = scrollView.minimumZoomScale
            let currentZoom = scrollView.zoomScale
            let newZoomScale: CGFloat
            if abs(currentZoom - maxZoom) < 0.01 || currentZoom > maxZoom - 0.01 {
                // If at or above max zoom, zoom out to min (1)
                newZoomScale = minZoom
            } else {
                // Otherwise, jump directly to max zoom
                newZoomScale = maxZoom
            }
            let zoomRect = self.zoomRect(for: scrollView, scale: newZoomScale, center: pointInView)
            scrollView.zoom(to: zoomRect, animated: true)
        }
        
        private func zoomRect(for scrollView: UIScrollView, scale: CGFloat, center: CGPoint) -> CGRect {
            let size = CGSize(
                width: scrollView.bounds.size.width / scale,
                height: scrollView.bounds.size.height / scale
            )
            let origin = CGPoint(
                x: center.x - size.width / 2.0,
                y: center.y - size.height / 2.0
            )
            return CGRect(origin: origin, size: size)
        }
        
        public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            DispatchQueue.main.async { [weak self] in
                self?.userInteracting.wrappedValue = true
            }
        }

        public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            DispatchQueue.main.async { [weak self] in
                self?.userInteracting.wrappedValue = false
                self?.contentOffset.wrappedValue = scrollView.contentOffset
            }
        }
        
        public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            DispatchQueue.main.async { [weak self] in
                self?.userInteracting.wrappedValue = false
                self?.contentOffset.wrappedValue = scrollView.contentOffset
            }
        }
        
        public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
            DispatchQueue.main.async { [weak self] in
                self?.userInteracting.wrappedValue = true
            }
        }

        public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
            DispatchQueue.main.async { [weak self] in
                self?.userInteracting.wrappedValue = false
                self?.centerContent()
            }
        }

        public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            scrollView.subviews.first
        }
        
        public func scrollViewDidZoom(_ scrollView: UIScrollView) {
            DispatchQueue.main.async { [weak self] in
                self?.zoomScale.wrappedValue = scrollView.zoomScale
                self?.contentOffset.wrappedValue = scrollView.contentOffset
                self?.centerContent()
            }
        }
    }
}
