//
//  TimeCardDetailViewController.swift
//  Ponto-MVC
//
//  Created by Carolina Cruz Agra Lopes on 09/07/22.
//

import UIKit

class TimeCardDetailViewController: UIViewController {

    // MARK: - Properties

    /// View
    private lazy var timeCardDetailView = TimeCardDetailView()

    /// Injected dependencies
    private(set) var timeCard: TimeCard

    /// Timers
    private var timeCardDurationTimer: Timer?
    private var breakDurationTimer: Timer?

    // MARK: - Initializers

    init(timeCard: TimeCard) {
        self.timeCard = timeCard
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life cycle

    override func loadView() {
        view = timeCardDetailView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        timeCardDetailView.tableView.dataSource = self

        // Set view title
        title = CommonFormatters.shared.longDayDateFormatter.string(from: timeCard.startDate)
        navigationItem.largeTitleDisplayMode = .never

        // Set duration label
        guard let durationText = CommonFormatters.shared.durationDateComponentsFormatter.string(from: timeCard.duration) else {
            print("Error when getting the time card's duration")
            return
        }
        timeCardDetailView.durationLabel.text = durationText
    }

}

extension TimeCardDetailViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        // If there are no breaks, there's only one section (for the start and end dates)
        // If there are any breaks, there's one additional section for each one
        timeCard.breaks.count + 1
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // The first section doesn't have a title and the other ones are named "Break <break number>"
        // The section numbers start at 0, so the first section is number 0
        section == 0 ? "" : String(format: Constants.TimeCardDetails.numberedBreakSectionHeaderTitle, section)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? Constants.TimeCardDetails.timeCardSectionRowCount : Constants.TimeCardDetails.breakSectionRowCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TimeCardDetailTableViewCell.reuseIdentifier, for: indexPath) as? TimeCardDetailTableViewCell else {
            return UITableViewCell()
        }

        if indexPath.section == 0 {
            configureTimeCardSectionCell(cell, forRow: indexPath.row)
        } else {
            configureBreakSectionCell(cell, forRowAt: indexPath)
        }

        return cell
    }

    private func configureTimeCardSectionCell(_ cell: TimeCardDetailTableViewCell, forRow row: Int) {
        guard let endDate = timeCard.endDate else {
            assertionFailure("Only finished time cards should be used in a TimeCardDetailTableViewController")
            return
        }

        switch row {
        case 0:
            cell.textLabel?.text = Constants.TimeCardDetails.clockInTimeCellTitle
            cell.detailTextLabel?.text = CommonFormatters.shared.timeDateFormatter.string(from: timeCard.startDate)
        case 1:
            cell.textLabel?.text = Constants.TimeCardDetails.clockOutTimeCellTitle
            cell.detailTextLabel?.text = CommonFormatters.shared.timeDateFormatter.string(from: endDate)
        default:
            assertionFailure("There are more than two rows at the first section")
        }
    }

    private func configureBreakSectionCell(_ cell: TimeCardDetailTableViewCell, forRowAt indexPath: IndexPath) {
        let breaks = timeCard.breaks
        let breakIndex = indexPath.section-1

        guard breakIndex < breaks.count else {
            assertionFailure("There are more break sections then the number of breaks")
            return
        }

        switch indexPath.row {
        case 0:
            cell.textLabel?.text = Constants.TimeCardDetails.breakStartTimeCellTitle
            cell.detailTextLabel?.text = CommonFormatters.shared.timeDateFormatter.string(from: breaks[breakIndex].startDate)
        case 1:
            cell.textLabel?.text = Constants.TimeCardDetails.breakEndTimeCellTitle
            if let endDate = breaks[breakIndex].endDate {
                cell.detailTextLabel?.text = CommonFormatters.shared.timeDateFormatter.string(from: endDate)
            } else {
                cell.detailTextLabel?.text = Constants.TimeCardDetails.timePlaceholder
            }
        case 2:
            cell.textLabel?.text = Constants.TimeCardDetails.breakDurationCellTitle
            if breaks[breakIndex].endDate != nil {
                cell.detailTextLabel?.text = CommonFormatters.shared.durationDateComponentsFormatter.string(from: breaks[breakIndex].duration)
            } else {
                cell.detailTextLabel?.text = Constants.TimeCardDetails.ongoingBreakIndicator
            }
        default:
            assertionFailure("There are more than three rows at a break section")
        }
    }

}
