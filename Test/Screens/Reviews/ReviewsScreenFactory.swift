final class ReviewsScreenFactory {

    /// Создаёт контроллер списка отзывов, проставляя нужные зависимости.
    func makeReviewsController() -> ReviewsViewController {
        let reviewsProvider = ReviewsProvider()
        let avatarService = AvatarServiceImpl()
        let viewModel = ReviewsViewModel(reviewsProvider: reviewsProvider, avatarService: avatarService)
        let controller = ReviewsViewController(viewModel: viewModel)
        return controller
    }

}
