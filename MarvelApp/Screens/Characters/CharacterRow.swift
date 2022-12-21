import Combine
import Kingfisher
import UIKit

typealias CharacterCell = CollectionViewCell<CharacterRow>

final class CharacterRow: UIView, ReusableView {

    var avatarImageView = UIImageView()
    var favoriteImageView = UIImageView()
    var nameLabel = UILabel()
    var descriptionLabel = UILabel()
    var storiesLabel = UILabel()
    var dateLabel = UILabel()

    private var cancellables: Set<AnyCancellable> = []

    var viewModel: CharacterRowViewModel? {
        didSet { setupViewModel() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupStyle()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func setupViewModel() {

        cancellables.removeAll()

        guard let viewModel = viewModel else { return }

        viewModel.$characterName
            .assign(to: \.text, on: nameLabel)
            .store(in: &cancellables)
        viewModel.$characterDescription
            .assign(to: \.text, on: descriptionLabel)
            .store(in: &cancellables)
        viewModel.$storiesCount
            .assign(to: \.text, on: storiesLabel)
            .store(in: &cancellables)
        viewModel.$lastModified
            .assign(to: \.text, on: dateLabel)
            .store(in: &cancellables)

        viewModel.$isFavorite
            .map { $0 ? "star.fill" : "star" }
            .map {
                UIImage(
                    systemName: $0,
                    withConfiguration: UIImage.SymbolConfiguration(
                        font: .preferredFont(forTextStyle: .headline)
                    )
                )?.withRenderingMode(.alwaysOriginal)
            }
            .assign(to: \.image, on: favoriteImageView)
            .store(in: &cancellables)

        viewModel.$imageURL
            .sink { [weak self] url in
                self?.avatarImageView.kf.setImage(with: url)
            }
            .store(in: &cancellables)
    }

    func setupViews() {

        translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        favoriteImageView.translatesAutoresizingMaskIntoConstraints = false
        storiesLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false

        nameLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        descriptionLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        storiesLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        dateLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        storiesLabel.setContentHuggingPriority(.defaultLow, for: .vertical)

        addSubview(avatarImageView)
        addSubview(nameLabel)
        addSubview(descriptionLabel)
        addSubview(favoriteImageView)
        addSubview(storiesLabel)
        addSubview(dateLabel)

        NSLayoutConstraint.activate([
            avatarImageView.widthAnchor.constraint(equalToConstant: 55),
            avatarImageView.heightAnchor.constraint(equalToConstant: 55),
            avatarImageView.centerYAnchor.constraint(equalTo: layoutMarginsGuide.centerYAnchor),
            avatarImageView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor, constant: 14),

            nameLabel.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor, constant: 5),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 5),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: favoriteImageView.leadingAnchor, constant: -5),

            descriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(lessThanOrEqualTo: layoutMarginsGuide.trailingAnchor),

            storiesLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 4),
            storiesLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            storiesLabel.trailingAnchor.constraint(lessThanOrEqualTo: dateLabel.leadingAnchor, constant: -5),
            storiesLabel.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor, constant: -5),

            dateLabel.firstBaselineAnchor.constraint(equalTo: storiesLabel.firstBaselineAnchor),
            dateLabel.trailingAnchor.constraint(lessThanOrEqualTo: layoutMarginsGuide.trailingAnchor),

            favoriteImageView.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            favoriteImageView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
        ])
    }

    func setupStyle() {

        avatarImageView.backgroundColor = .tertiarySystemGroupedBackground
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = 10
        avatarImageView.layer.cornerCurve = .continuous

        nameLabel.adjustsFontForContentSizeCategory = true
        descriptionLabel.adjustsFontForContentSizeCategory = true
        descriptionLabel.numberOfLines = 2
        storiesLabel.adjustsFontForContentSizeCategory = true
        dateLabel.adjustsFontForContentSizeCategory = true

        nameLabel.font = .preferredFont(forTextStyle: .headline)
        descriptionLabel.font = .preferredFont(forTextStyle: .caption1)
        storiesLabel.font = .preferredFont(forTextStyle: .footnote)
        dateLabel.font = .preferredFont(forTextStyle: .footnote)

        nameLabel.textColor = .label
        descriptionLabel.textColor = .label
        storiesLabel.textColor = .secondaryLabel
        dateLabel.textColor = .secondaryLabel
    }

    // MARK: - ReusableView

    func prepareForReuse() {
        avatarImageView.kf.cancelDownloadTask()
        avatarImageView.image = nil
        cancellables.removeAll()
    }
}
