import UIKit

enum CellUpdateType {
    case insertRows([IndexPath])
    case reloadRow(IndexPath)
}
/// Класс, описывающий бизнес-логику экрана отзывов.
final class ReviewsViewModel: NSObject {

    /// Замыкание, вызываемое при изменении `state`.
    var onStateChange: ((CellUpdateType) -> Void)?

    private var state: State
    private let reviewsProvider: ReviewsProvider
    private let ratingRenderer: RatingRenderer
    private var isCountShown = false
    private let decoder: JSONDecoder
    private let avatarService: AvatarService

    init(
        state: State = State(),
        reviewsProvider: ReviewsProvider = ReviewsProvider(),
        ratingRenderer: RatingRenderer = RatingRenderer(),
        avatarService: AvatarService,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.state = state
        self.reviewsProvider = reviewsProvider
        self.ratingRenderer = ratingRenderer
        self.avatarService = avatarService
        self.decoder = decoder
    }

}

// MARK: - Internal

extension ReviewsViewModel {

    typealias State = ReviewsViewModelState

    /// Метод получения отзывов.
    func getReviews() async {
        guard state.shouldLoad else { return }
        state.shouldLoad = false
        do {
            let data = try await reviewsProvider.getReviews(offset: state.offset)
            let reviews = try decoder.decode(Reviews.self, from: data)
            let totalCount = reviews.count
            let newReviewItems = await reviews.items.asyncMap(makeReviewItem)
            state.offset += state.limit
            state.shouldLoad = state.offset < reviews.count

            await MainActor.run {
                let start = state.items.count
                if state.items.count + newReviewItems.count > totalCount {
                    let countToAdd = totalCount - state.items.count
                    state.items += newReviewItems.prefix(countToAdd).map { $0 as any TableCellConfig }
                } else {
                    state.items += newReviewItems
                }

                state.offset += state.limit

                if state.items.count >= totalCount {
                    state.shouldLoad = false
                } else {
                    state.shouldLoad = true
                }

                isCountShown = !state.shouldLoad

                var newIndexPaths = (start..<state.items.count).map { IndexPath(row: $0, section: 0) }
                if isCountShown {
                    let summaryIndexPath = IndexPath(row: state.items.count, section: 0)
                    newIndexPaths.append(summaryIndexPath)
                }

                onStateChange?(.insertRows(newIndexPaths))
            }
        } catch {
            state.shouldLoad = true
        }
    }


}

// MARK: - Private

private extension ReviewsViewModel {
    /// Метод, вызываемый при нажатии на кнопку "Показать полностью...".
    /// Снимает ограничение на количество строк текста отзыва (раскрывает текст).
    func showMoreReview(with id: UUID) {
        guard
            let index = state.items.firstIndex(where: { ($0 as? ReviewItem)?.id == id }),
            var item = state.items[index] as? ReviewItem
        else { return }
        item.maxLines = .zero
        state.items[index] = item
        onStateChange?(.reloadRow(IndexPath(row: index, section: 0)))
        //TODO: показать полностью
    }

}

// MARK: - Items

private extension ReviewsViewModel {

    typealias ReviewItem = ReviewCellConfig

    func makeReviewItem(_ review: Review) async -> ReviewItem {
        let reviewText = review.text.attributed(font: .text)
        let created = review.created.attributed(font: .created, color: .created)
        let username = review.username.attributed(font: .username)
        let ratingImage = ratingRenderer.ratingImage(review.rating)
        let avatarImage: UIImage

        if let url = review.avatarUrl {
            avatarImage = await avatarService.fetchAvatar(from: url)
        } else {
            avatarImage = avatarService.defaultImage
        }

        let item = ReviewItem(
            username: username,
            reviewText: reviewText,
            created: created,
            ratingImage: ratingImage,
            avatarImage: avatarImage,
            onTapShowMore: { [weak self] id in
                guard let self else { return }
                showMoreReview(with: id)
            }
        )
        return item
    }

}

// MARK: - UITableViewDataSource

extension ReviewsViewModel: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !isCountShown {
            return state.items.count
        } else {
            return state.items.count + 1
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let isSummaryRow = (isCountShown && indexPath.row == state.items.count)
        if !isSummaryRow {
            let config = state.items[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: config.reuseId, for: indexPath)
            config.update(cell: cell)
            return cell
        } else {
            let summaryConfig = ReviewCountCellConfig(totalCount: state.items.count)
            let cell = tableView.dequeueReusableCell(withIdentifier: ReviewCountCellConfig.reuseId, for: indexPath)
            summaryConfig.update(cell: cell)
            return cell
        }
    }

}

// MARK: - UITableViewDelegate

extension ReviewsViewModel: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let isSummaryRow = (isCountShown && indexPath.row == state.items.count)
        if !isSummaryRow {
            return state.items[indexPath.row].height(with: tableView.bounds.size)
        } else {
            let summaryConfig = ReviewCountCellConfig(totalCount: state.items.count)
            return summaryConfig.height(with: tableView.bounds.size)
        }
    }

    /// Метод дозапрашивает отзывы, если до конца списка отзывов осталось два с половиной экрана по высоте.
    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        if shouldLoadNextPage(scrollView: scrollView, targetOffsetY: targetContentOffset.pointee.y) {
            Task {
                await getReviews()
            }
        }
    }

    private func shouldLoadNextPage(
        scrollView: UIScrollView,
        targetOffsetY: CGFloat,
        screensToLoadNextPage: Double = 2.5
    ) -> Bool {
        let viewHeight = scrollView.bounds.height
        let contentHeight = scrollView.contentSize.height
        let triggerDistance = viewHeight * screensToLoadNextPage
        let remainingDistance = contentHeight - viewHeight - targetOffsetY
        return remainingDistance <= triggerDistance
    }
}

