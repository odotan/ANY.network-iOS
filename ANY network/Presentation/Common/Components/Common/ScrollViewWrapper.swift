import SwiftUI

public struct ScrollViewWrapper<Content: View>: UIViewRepresentable {
    @Binding var contentOffset: CGPoint
    @Binding var contentSize: CGSize
    @Binding var size: CGSize
    @Binding var zoomScale: CGFloat
    
    let animationDuration: CGFloat
    let maxZoomLevel: CGFloat
    let content: () -> Content
    
    public init(
        contentOffset: Binding<CGPoint>,
        contentSize: Binding<CGSize>,
        size: Binding<CGSize>,
        zoomScale: Binding<CGFloat>,
        animationDuration: CGFloat = 0.35,
        maxZoomLevel: CGFloat = 2,
        @ViewBuilder _ content: @escaping () -> Content) {
            self._contentOffset = contentOffset
            self._contentSize = contentSize
            self._size = size
            self._zoomScale = zoomScale
            self.animationDuration = animationDuration
            self.maxZoomLevel = maxZoomLevel
            self.content = content
        }
    
    public func makeUIView(context: UIViewRepresentableContext<ScrollViewWrapper>) -> UIScrollView {
        let view = UIScrollView()
        view.delegate = context.coordinator
        view.maximumZoomScale = maxZoomLevel
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        
        // Instantiate the UIHostingController with the SwiftUI view
        let controller = UIHostingController(rootView: content())
        controller.view.translatesAutoresizingMaskIntoConstraints = false  // Disable autoresizing
        view.addSubview(controller.view)
        
        controller.view.sizeToFit()
        view.contentSize = controller.view.bounds.size
        
        context.coordinator.hostingController = controller

        return view
    }
    
    public func updateUIView(_ uiView: UIScrollView, context: UIViewRepresentableContext<ScrollViewWrapper>) {
        DispatchQueue.main.async {
            context.coordinator.hostingController.rootView = content()
            context.coordinator.hostingController.view.sizeToFit()
            uiView.contentSize = context.coordinator.hostingController.view.frame.size
        }

        UIView.animate(withDuration: animationDuration) {
            uiView.contentOffset = self.contentOffset
            uiView.zoomScale = self.zoomScale
        }
        
        DispatchQueue.main.async {
            self.contentSize = uiView.contentSize
            self.size = uiView.frame.size
            self.contentOffset = uiView.contentOffset

            // Update the frame of the hosted view if necessary
            if let hostedView = uiView.subviews.first {
                hostedView.frame = CGRect(origin: .zero, size: uiView.contentSize)
            }
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(contentOffset: self._contentOffset, zoomScale: self._zoomScale)
    }
    
    public class Coordinator: NSObject, UIScrollViewDelegate {
        let contentOffset: Binding<CGPoint>
        let zoomScale: Binding<CGFloat>
        
        var hostingController: UIHostingController<Content>!

        init(contentOffset: Binding<CGPoint>, zoomScale: Binding<CGFloat>) {
            self.contentOffset = contentOffset
            self.zoomScale = zoomScale
        }
        
        public func scrollViewDidScroll(_ scrollView: UIScrollView) {
            DispatchQueue.main.async { [weak self] in
                self?.contentOffset.wrappedValue = scrollView.contentOffset
            }
        }
        
        public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            scrollView.subviews.first
        }
        
        public func scrollViewDidZoom(_ scrollView: UIScrollView) {
            DispatchQueue.main.async { [weak self] in
                self?.zoomScale.wrappedValue = scrollView.zoomScale
            }
        }
    }
}
