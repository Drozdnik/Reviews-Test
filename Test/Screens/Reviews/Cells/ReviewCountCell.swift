import UIKit

final class ReviewCountCell: UITableViewCell {
    let countLabel = UILabel()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    private func setupCell() {
        contentView.addSubview(countLabel)
        countLabel.font = .reviewCount
        countLabel.textColor = .reviewCount
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            countLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            countLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            countLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor),
            countLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor)
        ])
    }
}
