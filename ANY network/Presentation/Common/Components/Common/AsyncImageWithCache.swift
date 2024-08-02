import SwiftUI
import Combine

class ImageCache {
    static let shared = NSCache<NSString, UIImage>()

    static func image(forKey key: String) -> UIImage? {
        return shared.object(forKey: key as NSString)
    }

    static func setImage(_ image: UIImage, forKey key: String) {
        shared.setObject(image, forKey: key as NSString)
    }
}

struct AsyncImageWithCache: View {
    @State private var uiImage: UIImage?
    @State private var cancellable: AnyCancellable?

    let imageData: Data?
    let cacheKey: String
    
    var body: some View {
        Image(uiImage: uiImage ?? UIImage())
            .resizable()
            .scaledToFill()
            .onAppear {
                loadImage()
            }
            .onDisappear {
                cancellable?.cancel()
            }
    }

    private func loadImage() {
        if let cachedImage = ImageCache.image(forKey: cacheKey) {
            self.uiImage = cachedImage
            return
        }

        guard let imageData = imageData else { return }

        cancellable = Just(imageData)
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .map { UIImage(data: $0) }
            .receive(on: DispatchQueue.main)
            .sink { image in
                if let image = image {
                    ImageCache.setImage(image, forKey: self.cacheKey)
                }
                self.uiImage = image
            }
    }
}
