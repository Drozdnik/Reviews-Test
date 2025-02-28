import UIKit

protocol AvatarService {
    func fetchAvatar(from url: URL?) async -> UIImage
}

final class AvatarServiceImpl: AvatarService {
    private let networkingService: NetworkingService = NetworkingServiceImpl()
    private let defaultImage: UIImage =  UIImage(named: avatarImageName) ?? UIImage(systemName: mockAvatarImageName)!

    func fetchAvatar(from url: URL?) async -> UIImage {
        guard let url else { return defaultImage }

        let avatarImage = await networkingService.fetchImage(urls: [url])
        if let avatar = avatarImage.first {
            return avatar ?? defaultImage
        } else {
            return defaultImage
        }
    }
}

private let avatarImageName = "mockAvatar"
private let mockAvatarImageName = "person.circle.fill"
