import Combine
import Foundation
import MarvelService
import UIKit

final class CharactersViewController: UICollectionViewController {

    var viewModel: CharactersViewModel

    private var refreshControl: UIRefreshControl!
    private var segmentedControl: UISegmentedControl!

    private lazy var dataSource = CharactersDiffableDataSource(collectionView: collectionView)
    private var cancellables: Set<AnyCancellable> = []

    init(viewModel: CharactersViewModel) {
        self.viewModel = viewModel

        var layoutConfig = UICollectionLayoutListConfiguration(appearance: .plain)
        layoutConfig.showsSeparators = true
        super.init(collectionViewLayout: UICollectionViewCompositionalLayout.list(using: layoutConfig))
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.onAppear()
    }

    /// Create and setup subviews. Setup view hierarchy and constraints.
    private func setupViews() {
        // view.backgroundColor = Colors.surface.primary

        refreshControl = UIRefreshControl(frame: .zero, primaryAction: .init(handler: { [weak self] _ in
            self?.viewModel.pulledToRefresh()
        }))
        collectionView.refreshControl = refreshControl
        collectionView.register(CharacterCell.self)
        collectionView.dataSource = dataSource
        collectionView.showsVerticalScrollIndicator = true
        collectionView.delegate = self

        segmentedControl = UISegmentedControl(frame: CGRect(x: 0, y: 0, width: 200, height: 32))
        navigationItem.titleView = segmentedControl
    }

    /// Setups bindings to and from the view model
    private func setupViewModel() {

        viewModel.$title
            .sink { [weak self] t in self?.navigationItem.title = t }
            .store(in: &cancellables)

        viewModel.$sortBy
            .sink { [weak self] options in
                guard let self = self else { return }
                self.segmentedControl.removeAllSegments()
                options.forEach { option in
                    self.segmentedControl.insertSegment(
                        action: UIAction(
                            title: option.title,
                            handler: { [weak self] _ in
                                self?.viewModel.sortBySelection = option
                            }
                        ),
                        at: self.segmentedControl.numberOfSegments,
                        animated: false
                    )
                }
            }
            .store(in: &cancellables)

        viewModel.$sortBySelection
            .compactMap { [viewModel] selection in
                return viewModel.sortBy.firstIndex(of: selection)
            }
            .sink { [weak self] index in
                self?.segmentedControl.selectedSegmentIndex = index
            }
            .store(in: &cancellables)

        viewModel.$sections
            .sink { [weak self] sections in
                self?.dataSource.reload(with: sections)
            }
            .store(in: &cancellables)

        viewModel.$dialogViewModel
            .compactMap { $0 }
            .sink { [weak self] dialogViewModel in
                self?.present(UIAlertController(dialogViewModel: dialogViewModel), animated: true)
            }
            .store(in: &cancellables)

//        viewModel.showCharacter
//            .sink { [weak self] id in
//                let vc = UIHostingController(rootView: CharacterDetailsView(characterID: id, marvelService: globalDIContainer.resolve()))
//                self?.present(vc, animated: true)
//            }
//            .store(in: &cancellables)

        viewModel.$isLoading
            .debounce(for: .seconds(0.25), scheduler: DispatchQueue.main)
            .sink { [weak self] loading in
                self?.refreshControl.endRefreshing()
            }
            .store(in: &cancellables)
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cellViewModel = dataSource.itemIdentifier(for: indexPath) else { return }
        viewModel.didSelect(cellViewModel)
    }

}

class CharactersDiffableDataSource: UICollectionViewDiffableDataSource<CharactersSection, CharacterRowViewModel> {

    init(collectionView: UICollectionView) {

        super.init(collectionView: collectionView) { collectionView, indexPath, viewModel in
            let cell = collectionView.dequeue(CharacterCell.self, for: indexPath)
            cell.view.viewModel = viewModel
            return cell
        }
    }

    func reload(with sections: [CharactersSection]) {

        var snapshot: NSDiffableDataSourceSnapshot<CharactersSection, CharacterRowViewModel> = .init()

        snapshot.appendSections(sections)

        sections.forEach {
            snapshot.appendItems($0.rowViewModels, toSection: $0)
        }

        apply(snapshot, animatingDifferences: false)
    }
}
