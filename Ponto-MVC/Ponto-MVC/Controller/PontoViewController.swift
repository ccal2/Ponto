//
//  PontoViewController.swift
//  Ponto-MVC
//
//  Created by Carolina Cruz Agra Lopes on 19/09/22.
//

import UIKit

class PontoViewController: UITabBarController {

    // MARK: - Properties

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

        let currentTimeCardViewController =  CurrentTimeCardViewController(timeCardRepository: timeCardRepository,
                                                                           currentDateProvider: currentDateProvider)
        let currentTimeCardNavigationController = UINavigationController(rootViewController: currentTimeCardViewController)
        currentTimeCardNavigationController.tabBarItem = UITabBarItem(title: Constants.CurrentTimeCard.tabBarTitle,
                                                                      image: UIImage(systemName: Constants.ImageName.calendarIcon),
                                                                      tag: 0)

        let timeCardHistoryViewController = TimeCardHistoryViewController(timeCardRepository: timeCardRepository,
                                                                          currentDateProvider: currentDateProvider)
        let timeCardHistoryNavigationController = UINavigationController(rootViewController: timeCardHistoryViewController)
        timeCardHistoryNavigationController.tabBarItem = UITabBarItem(title: Constants.TimeCardHistory.screenTitle,
                                                                      image: UIImage(systemName: Constants.ImageName.clockIcon),
                                                                      tag: 0)

        viewControllers = [currentTimeCardNavigationController, timeCardHistoryNavigationController]
    }

}
