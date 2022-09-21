//
//  PontoMacViewController.swift
//  Ponto-MVC
//
//  Created by Carolina Cruz Agra Lopes on 19/09/22.
//

import UIKit

class PontoMacViewController: UISplitViewController {

    // MARK: - Properties

    /// Injected dependencies
    private let timeCardRepository: TimeCardRepository
    private var currentDateProvider: CurrentDateProvider

    // MARK: - Initializers

    init(timeCardRepository: TimeCardRepository = LocalTimeCardRepository.shared, currentDateProvider: CurrentDateProvider = DateProvider.shared) {
        self.timeCardRepository = timeCardRepository
        self.currentDateProvider = currentDateProvider
        super.init(style: .doubleColumn)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        primaryBackgroundStyle = .sidebar
        preferredDisplayMode = .oneBesideSecondary

        let sidebarViewController = SidebarViewController(timeCardRepository: timeCardRepository, currentDateProvider: currentDateProvider)

        setViewController(sidebarViewController, for: .primary)
    }

}
