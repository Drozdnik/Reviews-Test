import UIKit

struct ReviewCountCellConfig {
    static let reuseIdentifier = String(describing: ReviewCountCell.self)

    private let count: Int?

    init(totalCount: Int?) {
        count = totalCount
    }
}

extension ReviewCountCellConfig: TableCellConfig {

    func update(cell: UITableViewCell) {
        guard let cell = cell as? ReviewCountCell, let count else { return }
        cell.countLabel.text = "\(count) отзывов"
        cell.countLabel.textAlignment = .center
    }

    func height(with size: CGSize) -> CGFloat {
        UIFont.reviewCount.lineHeight
    }
}

