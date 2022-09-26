//
//  SidebarViewController.swift
//  Ponto-MVC
//
//  Created by Carolina Cruz Agra Lopes on 20/09/22.
//

import UIKit

class SidebarViewController: UIViewController {

    // MARK: - Auxiliary structs

    private struct SidebarItem: Hashable, Identifiable {
        let id: UUID
        let title: String
        let image: UIImage?

        static func row(title: String, image: UIImage?, id: UUID = UUID()) -> Self {
            return SidebarItem(id: id, title: title, image: image)
        }
    }

    private struct RowIdentifier {
        static let today = UUID()
        static let history = UUID()
    }

    // MARK: - Properties

    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Int, SidebarItem>!

    /// View controllers
    lazy var currentNavigationTimeCardViewController: UINavigationController = {
        UINavigationController(rootViewController: CurrentTimeCardViewController(timeCardRepository: timeCardRepository, currentDateProvider: currentDateProvider))
    }()

    lazy var historyNavigationViewController: UINavigationController = {
        UINavigationController(rootViewController: TimeCardHistoryViewController(timeCardRepository: timeCardRepository, currentDateProvider: currentDateProvider))
    }()

    /// Injected dependencies
    private let timeCardRepository: TimeCardRepository
    private var currentDateProvider: CurrentDateProvider

    // MARK: - Initializers

    init(timeCardRepository: TimeCardRepository = LocalTimeCardRepository.shared, currentDateProvider: CurrentDateProvider = DateProvider.shared) {
        self.timeCardRepository = timeCardRepository
        self.currentDateProvider = currentDateProvider
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        configureCollectionView()
        configureDataSource()
        applyInitialSnapshot()

        splitViewController?.setViewController(currentNavigationTimeCardViewController, for: .secondary)
    }

}

// MARK: -

extension SidebarViewController {

    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        view.addSubview(collectionView)
    }

    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout() { (_, layoutEnvironment) -> NSCollectionLayoutSection? in
            var configuration = UICollectionLayoutListConfiguration(appearance: .sidebar)
            configuration.showsSeparators = false
            configuration.headerMode = .firstItemInSection
            let section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
            return section
        }
        return layout
    }

}

// MARK: - UICollectionViewDelegate

extension SidebarViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let sidebarItem = dataSource.itemIdentifier(for: indexPath) else { return }

        switch sidebarItem.id {
        case RowIdentifier.today:
            splitViewController?.setViewController(currentNavigationTimeCardViewController, for: .secondary)
        case RowIdentifier.history:
            splitViewController?.setViewController(historyNavigationViewController, for: .secondary)
        default:
            assertionFailure("There are more than two rows at the sidebar")
        }
    }

}

// MARK: - Data source

extension SidebarViewController {

    private func configureDataSource() {
        let rowRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, SidebarItem> { (cell, _, item) in
            var contentConfiguration = UIListContentConfiguration.sidebarSubtitleCell()
            contentConfiguration.text = item.title
            contentConfiguration.image = item.image

            cell.contentConfiguration = contentConfiguration
        }

        dataSource = UICollectionViewDiffableDataSource<Int, SidebarItem>(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell in
            return collectionView.dequeueConfiguredReusableCell(using: rowRegistration, for: indexPath, item: item)
        }
    }

    private func applyInitialSnapshot() {
        var snapshot = NSDiffableDataSourceSectionSnapshot<SidebarItem>()
        let items: [SidebarItem] = [
            .row(title: Constants.CurrentTimeCard.tabBarTitle, image: UIImage(systemName: Constants.ImageName.calendarIcon), id: RowIdentifier.today),
            .row(title: Constants.TimeCardHistory.screenTitle, image: UIImage(systemName: Constants.ImageName.clockIcon), id: RowIdentifier.history)
        ]

        snapshot.append(items)

        dataSource.apply(snapshot, to: 0, animatingDifferences: false)
    }

}
