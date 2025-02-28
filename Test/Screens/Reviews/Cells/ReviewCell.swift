import UIKit

/// Конфигурация ячейки. Содержит данные для отображения в ячейке.
struct ReviewCellConfig {

    /// Идентификатор для переиспользования ячейки.
    static let reuseId = String(describing: ReviewCellConfig.self)

    /// Идентификатор конфигурации. Можно использовать для поиска конфигурации в массиве.
    let id = UUID()
    let username: NSAttributedString
    /// Текст отзыва.
    let reviewText: NSAttributedString
    /// Максимальное отображаемое количество строк текста. По умолчанию 3.
    var maxLines = 3
    /// Время создания отзыва.
    let created: NSAttributedString
    let ratingImage: UIImage
    let avatarImage: UIImage
    let images: [UIImage]
    /// Замыкание, вызываемое при нажатии на кнопку "Показать полностью...".
    let onTapShowMore: (UUID) -> Void




    /// Объект, хранящий посчитанные фреймы для ячейки отзыва.
    fileprivate let layout = ReviewCellLayout()

}

// MARK: - TableCellConfig

extension ReviewCellConfig: TableCellConfig {

    /// Метод обновления ячейки.
    /// Вызывается из `cellForRowAt:` у `dataSource` таблицы.
    func update(cell: UITableViewCell) {
        guard let cell = cell as? ReviewCell else { return }

        cell.avatarImageView.image = avatarImage
        cell.ratingImageView.image = ratingImage
        cell.usernameLabel.attributedText = username
        cell.reviewTextLabel.attributedText = reviewText
        cell.reviewTextLabel.numberOfLines = maxLines
        cell.createdLabel.attributedText = created
        cell.images = images
        cell.updateImagesStackView()
        cell.config = self
    }

    /// Метод, возвращаюший высоту ячейки с данным ограничением по размеру.
    /// Вызывается из `heightForRowAt:` делегата таблицы.
    func height(with size: CGSize) -> CGFloat {
        layout.height(config: self, maxWidth: size.width)
    }

}

// MARK: - Private

private extension ReviewCellConfig {

    /// Текст кнопки "Показать полностью...".
    static let showMoreText = "Показать полностью..."
        .attributed(font: .showMore, color: .showMore)

}

// MARK: - Cell

final class ReviewCell: UITableViewCell {

    fileprivate var config: Config?

    fileprivate let reviewTextLabel = UILabel()
    fileprivate let createdLabel = UILabel()
    fileprivate let showMoreButton = UIButton()
    fileprivate let avatarImageView = UIImageView()
    fileprivate let ratingImageView = UIImageView()
    fileprivate let usernameLabel = UILabel()
    fileprivate var images: [UIImage] = []
    fileprivate let imagesStackView = UIStackView()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let layout = config?.layout else { return }
        usernameLabel.frame = layout.usernameFrame
        avatarImageView.frame = layout.avatarFrame
        ratingImageView.frame = layout.ratingFrame
        reviewTextLabel.frame = layout.reviewTextLabelFrame
        createdLabel.frame = layout.createdLabelFrame
        showMoreButton.frame = layout.showMoreButtonFrame

        let hasImages = !images.isEmpty
        imagesStackView.frame = hasImages ? layout.imagesStackView : .zero
    }

}

// MARK: - Private

private extension ReviewCell {

    func setupCell() {
        setupUsername()
        setupReviewTextLabel()
        setupCreatedLabel()
        setupShowMoreButton()
        setupAvatarImageView()
        setupRatingImageView()
        setupImagesStackView()
    }

    func setupReviewTextLabel() {
        contentView.addSubview(reviewTextLabel)
        reviewTextLabel.lineBreakMode = .byWordWrapping
    }

    func setupCreatedLabel() {
        contentView.addSubview(createdLabel)
    }

    func setupShowMoreButton() {
        contentView.addSubview(showMoreButton)
        showMoreButton.contentVerticalAlignment = .fill
        showMoreButton.setAttributedTitle(Config.showMoreText, for: .normal)
        showMoreButton.addAction(UIAction { [weak self] _ in
            guard let self = self, let config = self.config else { return }

            config.onTapShowMore(config.id)
        }, for: .touchUpInside)
    }

    func setupAvatarImageView() {
        contentView.addSubview(avatarImageView)
        avatarImageView.contentMode = .scaleAspectFit
        avatarImageView.layer.cornerRadius = ReviewCellLayout.avatarCornerRadius
        avatarImageView.clipsToBounds = true
    }

    func setupRatingImageView() {
        contentView.addSubview(ratingImageView)
        ratingImageView.contentMode = .scaleAspectFit
    }

    func setupUsername() {
        contentView.addSubview(usernameLabel)
    }

    func setupImagesStackView() {
        contentView.addSubview(imagesStackView)
        imagesStackView.axis = .horizontal
        imagesStackView.spacing = Layout.photosSpacing
    }

    func updateImagesStackView() {
        imagesStackView.arrangedSubviews.forEach{ $0.removeFromSuperview() }

        guard !images.isEmpty else {
            imagesStackView.isHidden = true
            return
        }

        imagesStackView.isHidden = false
        images.forEach { image in
            let imageView = UIImageView(image: image)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: Layout.photoSize.width),
                imageView.heightAnchor.constraint(equalToConstant: Layout.photoSize.height)
            ])
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = Layout.photoCornerRadius
            imagesStackView.addArrangedSubview(imageView)
        }
    }
}

// MARK: - Layout

/// Класс, в котором происходит расчёт фреймов для сабвью ячейки отзыва.
/// После расчётов возвращается актуальная высота ячейки.
private final class ReviewCellLayout {

    // MARK: - Размеры

    fileprivate static let avatarSize = CGSize(width: 36.0, height: 36.0)
    fileprivate static let avatarCornerRadius = 18.0
    fileprivate static let photoCornerRadius = 8.0

    fileprivate static let photoSize = CGSize(width: 55.0, height: 66.0)
    private static let showMoreButtonSize = Config.showMoreText.size()

    /// Горизонтальные отступы между фото.
    fileprivate static let photosSpacing = 8.0

    // MARK: - Фреймы

    private(set) var reviewTextLabelFrame = CGRect.zero
    private(set) var showMoreButtonFrame = CGRect.zero
    private(set) var createdLabelFrame = CGRect.zero
    private(set) var avatarFrame = CGRect.zero
    private(set) var ratingFrame = CGRect.zero
    private(set) var usernameFrame = CGRect.zero
    private(set) var imagesStackView = CGRect.zero

    // MARK: - Отступы

    /// Отступы от краёв ячейки до её содержимого.
    private let insets = UIEdgeInsets(top: 9.0, left: 12.0, bottom: 9.0, right: 12.0)

    /// Горизонтальный отступ от аватара до имени пользователя.
    private let avatarToUsernameSpacing = 10.0
    /// Вертикальный отступ от имени пользователя до вью рейтинга.
    private let usernameToRatingSpacing = 6.0
    /// Вертикальный отступ от вью рейтинга до текста (если нет фото).
    private let ratingToTextSpacing = 6.0
    /// Вертикальный отступ от вью рейтинга до фото.
    private let ratingToPhotosSpacing = 10.0
    /// Вертикальный отступ от фото (если они есть) до текста отзыва.
    private let photosToTextSpacing = 10.0
    /// Вертикальный отступ от текста отзыва до времени создания отзыва или кнопки "Показать полностью..." (если она есть).
    private let reviewTextToCreatedSpacing = 6.0
    /// Вертикальный отступ от кнопки "Показать полностью..." до времени создания отзыва.
    private let showMoreToCreatedSpacing = 6.0

    // MARK: - Расчёт фреймов и высоты ячейки

    /// Возвращает высоту ячейку с данной конфигурацией `config` и ограничением по ширине `maxWidth`.
    func height(config: Config, maxWidth: CGFloat) -> CGFloat {
        let avatarContainerFrameStart = CGPoint(x: insets.left, y: insets.top)
        let reviewContainerStart = avatarContainerFrameStart.x + Self.avatarSize.width + avatarToUsernameSpacing
        let width = maxWidth - insets.left - insets.right - reviewContainerStart
        let reviewContainerFrameStart = CGPoint(
            x: avatarContainerFrameStart.x + Self.avatarSize.width + avatarToUsernameSpacing,
            y: insets.top
        )
        var maxY = insets.top
        var showShowMoreButton = false

        avatarFrame = CGRect(
            origin: avatarContainerFrameStart,
            size: Self.avatarSize
        )

        let usernameTextHeight = (config.username.font()?.lineHeight ?? .zero)
        usernameFrame = CGRect(
            origin: reviewContainerFrameStart,
            size: config.username.boundingRect(width: width, height: usernameTextHeight).size
        )

        maxY += usernameToRatingSpacing + usernameTextHeight

        ratingFrame = CGRect(origin:
                                CGPoint(
                                    x: reviewContainerFrameStart.x,
                                    y: maxY),
                             size: config.ratingImage.size
        )

        if !config.images.isEmpty {
            let stackWidth = CGFloat(config.images.count) * Self.photoSize.width + CGFloat(config.images.count - 1) * Self.photosSpacing
            maxY += config.ratingImage.size.height + ratingToPhotosSpacing
            imagesStackView = CGRect(
                x: reviewContainerFrameStart.x,
                y: maxY,
                width: stackWidth,
                height: Self.photoSize.height
            )

            maxY +=  Self.photoSize.height + photosToTextSpacing
        } else {
            maxY += config.ratingImage.size.height + ratingToTextSpacing
        }

        if !config.reviewText.isEmpty() {
            // Высота текста с текущим ограничением по количеству строк.
            let currentTextHeight = (config.reviewText.font()?.lineHeight ?? .zero) * CGFloat(config.maxLines)
            // Максимально возможная высота текста, если бы ограничения не было.
            let actualTextHeight = config.reviewText.boundingRect(width: width).size.height
            // Показываем кнопку "Показать полностью...", если максимально возможная высота текста больше текущей.
            showShowMoreButton = config.maxLines != .zero && actualTextHeight > currentTextHeight

            reviewTextLabelFrame = CGRect(
                origin: CGPoint(x: reviewContainerFrameStart.x, y: maxY),
                size: config.reviewText.boundingRect(width: width, height: currentTextHeight).size
            )
            maxY = reviewTextLabelFrame.maxY + reviewTextToCreatedSpacing
        }

        if showShowMoreButton {
            showMoreButtonFrame = CGRect(
                origin: CGPoint(x: reviewContainerFrameStart.x, y: maxY),
                size: Self.showMoreButtonSize
            )
            maxY = showMoreButtonFrame.maxY + showMoreToCreatedSpacing
        } else {
            showMoreButtonFrame = .zero
        }

        createdLabelFrame = CGRect(
            origin: CGPoint(x: reviewContainerFrameStart.x, y: maxY),
            size: config.created.boundingRect(width: width).size
        )

        return createdLabelFrame.maxY + insets.bottom
    }
}

// MARK: - Typealias

fileprivate typealias Config = ReviewCellConfig
fileprivate typealias Layout = ReviewCellLayout
