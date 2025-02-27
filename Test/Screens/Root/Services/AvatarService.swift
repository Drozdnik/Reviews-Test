import UIKit

protocol AvatarService {
    func fetchAvatar(from url: URL) async -> UIImage
    var defaultImage: UIImage { get }
}

final class AvatarServiceImpl: AvatarService {
    private var cache: [String: UIImage] = [:]
    let defaultImage: UIImage =  UIImage(named: avatarImageName) ?? UIImage(systemName: mockAvatarImageName)!

    func fetchAvatar(from url: URL) async -> UIImage {
        let key = url.absoluteString

        if let cached = cache[key] {
            return cached
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                cache[key] = image
                return image
            }
        } catch {
            assertionFailure("Не удалось запросить изображение по url: \(url)")
        }
        
        return defaultImage
    }
}

private let avatarImageName = "mockAvatar"
private let mockAvatarImageName = "person.circle.fill"
