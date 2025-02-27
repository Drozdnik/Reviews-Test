import Foundation
/// Модель отзыва.
struct Review: Decodable {
    private enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName  = "last_name"
        case rating
        case text
        case created
        case avatarUrl = "avatar_url"
    }
    
    /// Текст отзыва.
    let text: String
    /// Время создания отзыва.
    let created: String
    let rating: Int
    let avatarUrl: URL?
    var username: String {
        "\(firstName) \(lastName)"
    }

    private let firstName: String
    private let lastName: String
}


