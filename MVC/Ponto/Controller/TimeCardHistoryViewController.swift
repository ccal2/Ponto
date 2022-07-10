//
//  TimeCardHistoryViewController.swift
//  Ponto-MVC
//
//  Created by Carolina Cruz Agra Lopes on 18/06/22.
//

import UIKit

class TimeCardHistoryViewController: UITableViewController {

    // MARK: - Properties

    private(set) var timeCardsGroupedByMonth: [DateComponents: [TimeCard]] = [:]

    /// Sorted months by latest -> oldest
    var sortedMonths: [DateComponents] {
        timeCardsGroupedByMonth.keys.sorted { lhs, rhs in
            guard let lhsYear = lhs.year,
                  let lhsMonth = lhs.month,
                  let rhsYear = rhs.year,
                  let rhsMonth = rhs.month else {
                assertionFailure("The keys for `timeCardsGroupedByMonth` must all have year and month components")
                return false
            }

            if lhsYear > rhsYear {
                return true
            } else if lhsYear < rhsYear {
                return false
            } else {
                return lhsMonth > rhsMonth
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

        timeCardRepository.listFinished(limitedBy: nil) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case let .success(timeCards):
                self.timeCardsGroupedByMonth = Dictionary(grouping: timeCards) { timeCard in
                    timeCard.startDate.monthComponents
                }
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
        let numberOfSections = timeCardsGroupedByMonth.keys.count

        if numberOfSections == 0 {
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

        return numberOfSections
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sortedMonths = sortedMonths

        guard section < sortedMonths.count else {
            assertionFailure("There are more sections then the number of months")
            return ""
        }

        guard let monthDate = sortedMonths[section].date else {
            assertionFailure("Failed to get date from components")
            return ""
        }

        return CommonFormatters.shared.monthDateFormatter.string(from: monthDate)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        timeCardsGroupedByMonth[sortedMonths[section]]?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TimeCardDetailTableViewCell.reuseIdentifier, for: indexPath) as? TimeCardDetailTableViewCell else {
            return UITableViewCell()
        }

        let sortedMonths = sortedMonths

        guard indexPath.section < sortedMonths.count else {
            assertionFailure("There are more sections then the number of months")
            return cell
        }

        guard let timeCardsInSection = timeCardsGroupedByMonth[sortedMonths[indexPath.section]] else {
            assertionFailure("There are no timeCards for that month")
            return cell
        }

        guard indexPath.row < timeCardsInSection.count else {
            assertionFailure("There are more cells then the number of time cards in the month related to the section")
            return cell
        }

        cell.textLabel?.text = CommonFormatters.shared.mediumDayDateFormatter.string(from: timeCardsInSection[indexPath.row].startDate)
        cell.detailTextLabel?.text = CommonFormatters.shared.durationDateComponentsFormatter.string(from: timeCardsInSection[indexPath.row].duration)

        return cell
    }

}

// MARK: - UITableViewDelegate

extension TimeCardHistoryViewController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sortedMonths = sortedMonths

        guard indexPath.section < sortedMonths.count else {
            assertionFailure("There are more sections then the number of months")
            return
        }

        guard let timeCardsInSection = timeCardsGroupedByMonth[sortedMonths[indexPath.section]] else {
            assertionFailure("There are no timeCards for that month")
            return
        }

        guard indexPath.row < timeCardsInSection.count else {
            assertionFailure("There are more cells then the number of time cards in the month related to the section")
            return
        }

        let detailViewController = TimeCardDetailViewController(timeCard: timeCardsInSection[indexPath.row])
        navigationController?.pushViewController(detailViewController, animated: true)
    }

}
