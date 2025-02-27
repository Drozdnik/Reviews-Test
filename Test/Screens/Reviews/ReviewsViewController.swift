import UIKit

final class ReviewsViewController: UIViewController {

    private lazy var reviewsView = makeReviewsView()
    private let viewModel: ReviewsViewModel

    init(viewModel: ReviewsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = reviewsView
        title = "Отзывы"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
        startLoading()
        setupRefreshcontrol()
        Task { [weak self] in
            guard let self else { return }
           await viewModel.getReviews()
            endLoading()
        }
    }
}

// MARK: - Private

private extension ReviewsViewController {
    
    func makeReviewsView() -> ReviewsView {
        let reviewsView = ReviewsView()
        reviewsView.tableView.delegate = viewModel
        reviewsView.tableView.dataSource = viewModel
        return reviewsView
    }
    
    func setupViewModel() {
        viewModel.onStateChange = { [weak self] change in
            guard let self else { return }

            let tableView = reviewsView.tableView
            
            switch change {
            case .insertRows(let indexPaths):
                tableView.performBatchUpdates {
                    tableView.insertRows(at: indexPaths, with: .automatic)
                }
            case .reloadRow(let indexPath):
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
    }

    func startLoading() {
        reviewsView.loader.startAnimating()
    }

    func endLoading() {
        reviewsView.loader.stopAnimating()
    }

    func setupRefreshcontrol() {
        reviewsView.refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
    }

    @objc
    func didPullToRefresh() {
        Task { [weak self] in
            guard let self else { return }
            await viewModel.getReviews()

            await MainActor.run { [weak self] in
                guard let self else { return }
                reviewsView.tableView.refreshControl?.endRefreshing()
            }
        }
    }
}
