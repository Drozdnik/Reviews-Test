import UIKit

final class ReviewsView: UIView {

    let tableView = UITableView()
    let loader = CustomActivityIndicator()
    let refreshControl = UIRefreshControl()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        tableView.frame = bounds.inset(by: safeAreaInsets)
        loader.frame = CGRect(x: 0, y: 0, width: loaderSize, height: loaderSize)
        loader.position = self.center
    }

}

// MARK: - Private

private extension ReviewsView {

    func setupView() {
        backgroundColor = .systemBackground
        setupTableView()
        setupLoader()
        setupRefreshControl()
    }

    func setupTableView() {
        addSubview(tableView)
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.register(ReviewCell.self, forCellReuseIdentifier: ReviewCellConfig.reuseId)
        tableView.register(ReviewCountCell.self, forCellReuseIdentifier: ReviewCountCellConfig.reuseId)
    }

    func setupLoader() {
        self.layer.addSublayer(loader)
    }

    func setupRefreshControl() {
        tableView.refreshControl = refreshControl
    }
}

private let loaderSize = CGFloat(50)
