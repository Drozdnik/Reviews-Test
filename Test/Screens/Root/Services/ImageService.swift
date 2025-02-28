import UIKit

protocol ImageService {
    func fetchImages(urls: [URL?]?) async -> [UIImage]
}

final class ImageServiceImpl: ImageService {
    private let networkingService: NetworkingService = NetworkingServiceImpl()
    private let defaultImage = UIImage(systemName: "wifi.exclamationmark")!

    func fetchImages(urls: [URL?]?) async -> [UIImage] {
        guard let urls else { return [] }
        let validUrls = urls.compactMap{ $0 }
        guard !validUrls.isEmpty else { return [] }
        let result = await networkingService.fetchImage(urls: validUrls)
        return result.map { $0 ?? defaultImage }
    }
}
