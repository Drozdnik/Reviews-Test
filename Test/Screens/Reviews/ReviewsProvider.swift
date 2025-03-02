import Foundation


enum ReviewsError: Error{
    case badURL
    case badData(Error)
}

/// Класс для загрузки отзывов.
final class ReviewsProvider {

    private let bundle: Bundle

    init(bundle: Bundle = .main) {
        self.bundle = bundle
    }

}

// MARK: - Internal

extension ReviewsProvider {

    typealias GetReviewsResult = Result<Data, GetReviewsError>

    enum GetReviewsError: Error {

        case badURL
        case badData(Error)

    }

    func getReviews(offset: Int = 0) async throws -> Data {
        guard let url = bundle.url(forResource: "getReviews.response", withExtension: "json") else {
            throw ReviewsError.badURL
        }
        // Симулируем сетевой запрос - не менять
        try await Task.sleep(nanoseconds: UInt64.random(in: 100_000_000...1_000_000_000))


        return try Data(contentsOf: url)
    }
}
