import UIKit

protocol NetworkingService {
    func fetchImage(urls: [URL]) async ->  [UIImage?]
}

final class NetworkingServiceImpl: NetworkingService {
    private var cache =  [String: UIImage]()

    func fetchImage(urls: [URL]) async ->  [UIImage?] {
        var arr = [UIImage?]()

        for url in urls {
            let key = url.absoluteString

            if let cached = cache[key] {
                arr.append(cached)
                continue
            }

            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let image = UIImage(data: data) {
                    cache[key] = image
                    arr.append(image)
                } else {
                    arr.append(nil)
                }
            } catch {
                assertionFailure("Не удалось запросить изображение по url: \(url)")
                arr.append(nil)
            }
        }

        return arr
    }
}
