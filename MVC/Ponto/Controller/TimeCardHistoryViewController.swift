//
//  TimeCardHistoryViewController.swift
//  Ponto-MVC
//
//  Created by Carolina Cruz Agra Lopes on 18/06/22.
//

import UIKit

class TimeCardHistoryViewController: UITableViewController {

    // MARK: - Properties

    private(set) var timeCards: [TimeCard] = [] {
        didSet {
            timeCards = timeCards.filter { timeCard in
                timeCard.endDate != nil
            }
        }
    }

    /// Injected dependencies
    private let timeCardRepository: TimeCardRepository
    private var currentDateProvider: CurrentDateProvider

    // MARK: - Initializers

    init(timeCardRepository: TimeCardRepository = LocalTimeCardRepository.shared, currentDateProvider: CurrentDateProvider = DateProvider.sharedInstance) {
        self.timeCardRepository = timeCardRepository
        self.currentDateProvider = currentDateProvider
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life cycle

    override func loadView() {
        super.loadView()

        tableView.register(TimeCardDetailTableViewCell.self, forCellReuseIdentifier: TimeCardDetailTableViewCell.reuseIdentifier)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Constants.TimeCardHistory.screenTitle

        timeCardRepository.list { [weak self] result in
            guard let self = self else { return }

            switch result {
            case let .success(timeCards):
                self.timeCards = timeCards
            case let .failure(error):
                print("Error when trying to load time cards: \(error.localizedDescription)")
            }
        }

        tableView.reloadData()
    }

}

// MARK: - UITableViewDataSource

extension TimeCardHistoryViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rows = timeCards.count

        if rows == 0 {
            let rect = CGRect(x: 0.0, y: 0.0, width: tableView.bounds.size.width, height: tableView.bounds.size.height)
            let messageLabel = UILabel(frame: rect)
            messageLabel.text = Constants.TimeCardHistory.emptyHistoryMessage
            messageLabel.numberOfLines = 0
            messageLabel.textAlignment = .center
            messageLabel.sizeToFit()

            tableView.backgroundView = messageLabel
            tableView.separatorStyle = .none
        } else {
            tableView.backgroundView = nil
        }

        return rows
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TimeCardDetailTableViewCell.reuseIdentifier, for: indexPath) as? TimeCardDetailTableViewCell else {
            return UITableViewCell()
        }

        guard indexPath.row < timeCards.count else {
            assertionFailure("There are more cells then the number of time cards")
            return cell
        }

        cell.textLabel?.text = CommonFormatters.shared.mediumDayDateFormatter.string(from: timeCards[indexPath.row].startDate)
        cell.detailTextLabel?.text = CommonFormatters.shared.durationDateComponentsFormatter.string(from: timeCards[indexPath.row].duration)

        return cell
    }

}
