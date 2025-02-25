/// Модель отзыва.
struct Review: Decodable {
    private enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName  = "last_name"
        case rating
        case text
        case created
    }
    
    /// Текст отзыва.
    let text: String
    /// Время создания отзыва.
    let created: String
    let rating: Int
    var username: String {
        "\(firstName) \(lastName)"
    }

    private let firstName: String
    private let lastName: String
}


