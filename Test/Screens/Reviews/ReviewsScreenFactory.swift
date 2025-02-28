final class ReviewsScreenFactory {

    /// Создаёт контроллер списка отзывов, проставляя нужные зависимости.
    func makeReviewsController() -> ReviewsViewController {
        let reviewsProvider = ReviewsProvider()
        let avatarService = AvatarServiceImpl()
        let imageService = ImageServiceImpl()
        let viewModel = ReviewsViewModel(reviewsProvider: reviewsProvider, avatarService: avatarService, imageService: imageService)
        let controller = ReviewsViewController(viewModel: viewModel)
        return controller
    }

}
