import SwiftUI

public struct ScrollViewWrapper<Content: View>: UIViewRepresentable {
    @Binding var contentOffset: CGPoint
    @Binding var contentSize: CGSize
    @Binding var size: CGSize
    @Binding var zoomScale: CGFloat
    
    @State var userInteracting: Bool = false
    
    var contentIdentifier: UUID

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
        contentId: UUID,
        @ViewBuilder _ content: @escaping () -> Content) {
            self._contentOffset = contentOffset
            self._contentSize = contentSize
            self._size = size
            self._zoomScale = zoomScale
            self.animationDuration = animationDuration
            self.maxZoomLevel = maxZoomLevel
            self.contentIdentifier = contentId
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
        let newContent = content()

        if context.coordinator.contentIdentifier != contentIdentifier {
            print("Scroll Refresh")
            DispatchQueue.main.async {
                context.coordinator.hostingController.rootView = newContent
                context.coordinator.hostingController.view.sizeToFit()
                uiView.contentSize = context.coordinator.hostingController.view.frame.size
                context.coordinator.contentIdentifier = contentIdentifier
            }
        }
        
        if (uiView.contentOffset != contentOffset/* || uiView.zoomScale != self.zoomScale*/) && !userInteracting {
            print("Animate Scroll View offset", contentOffset)
            UIView.animate(withDuration: animationDuration) {
                uiView.contentOffset = self.contentOffset
                uiView.zoomScale = self.zoomScale
            }
        }
        
        if contentSize != uiView.contentSize || size != uiView.frame.size /*|| contentOffset != uiView.contentOffset*/ {
            print("User scrolls")
            DispatchQueue.main.async {
                self.contentSize = uiView.contentSize
                self.size = uiView.frame.size
                
                // Update the frame of the hosted view if necessary
                if let hostedView = uiView.subviews.first {
                    hostedView.frame = CGRect(origin: .zero, size: uiView.contentSize)
                }
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

        var userInteracting: Binding<Bool>
    
        init(contentOffset: Binding<CGPoint>, zoomScale: Binding<CGFloat>, contentIdentifier: UUID?, userInteracting: Binding<Bool>) {
            self.contentOffset = contentOffset
            self.zoomScale = zoomScale
            self.contentIdentifier = contentIdentifier
            self.userInteracting = userInteracting
        }
        
        public func scrollViewDidScroll(_ scrollView: UIScrollView) {
            DispatchQueue.main.async { [weak self] in
//                print("didScroll", scrollView.contentOffset)
                self?.contentOffset.wrappedValue = scrollView.contentOffset
            }
        }
        
        public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//            print("scrollViewWillBeginDragging")
            DispatchQueue.main.async { [weak self] in
                self?.userInteracting.wrappedValue = true
            }
        }

        public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//             print("scrollViewWillEndDragging")
        }

        public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//            print("scrollViewDidEndDragging")
        }
        
        public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//            print("scrollViewDidEndDecelerating")
            DispatchQueue.main.async { [weak self] in
                self?.userInteracting.wrappedValue = false
            }
        }
        
//        public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
//            DispatchQueue.main.async { [weak self] in
//                self?.userInteracting.wrappedValue = true
//            }
//        }
//
//        public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
//            DispatchQueue.main.async { [weak self] in
//                self?.userInteracting.wrappedValue = false
//            }
//        }

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
