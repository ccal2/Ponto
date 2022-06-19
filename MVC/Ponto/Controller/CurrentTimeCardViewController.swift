//
//  CurrentTimeCardViewController.swift
//  Ponto-MVC
//
//  Created by Carolina Cruz Agra Lopes on 04/03/22.
//

import UIKit

class CurrentTimeCardViewController: UIViewController {

    // MARK: - Properties

    private(set) var timeCard: TimeCard? {
        didSet {
            timeCard?.delegate = self
            updateUI()
        }
    }

    /// View
    private lazy var currentTimeCardView = CurrentTimeCardView()

    /// Injected dependencies
    private let timeCardRepository: TimeCardRepository
    private var currentDateProvider: CurrentDateProvider

    /// Timers
    private var timeCardDurationTimer: Timer?
    private var breakDurationTimer: Timer?

    // MARK: - Initializers

    init(timeCardRepository: TimeCardRepository = LocalTimeCardRepository.shared, currentDateProvider: CurrentDateProvider = DateProvider.sharedInstance) {
        self.timeCardRepository = timeCardRepository
        self.currentDateProvider = currentDateProvider
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life cycle

    override func loadView() {
        currentTimeCardView.delegate = self
        view = currentTimeCardView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        currentTimeCardView.tableView.dataSource = self

        timeCardRepository.get(for: currentDateProvider.currentDate()) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case let .success(timeCard):
                self.timeCard = timeCard
            case let .failure(error):
                print("Error when trying to load the current time card: \(error.localizedDescription)")
            }
        }

        updateUI()
    }

    // MARK: - UI Update

    // swiftlint:disable function_body_length
    private func updateUI() {
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                self.updateUI()
            }
            return
        }

        switch timeCard?.state {
        case nil:
            navigationItem.title = CommonFormatters.shared.shortDayDateFormatter.string(from: currentDateProvider.currentDate())
            timeCardDurationTimer?.invalidate()
            timeCardDurationTimer = nil
            breakDurationTimer?.invalidate()
            breakDurationTimer = nil
            currentTimeCardView.durationLabel.text = Constants.TimeCardDetails.durationPlaceholder
            currentTimeCardView.breakLabel.isHidden = true
            currentTimeCardView.pauseContinueButton.setBackgroundImage(UIImage(systemName: Constants.ImageName.pauseButton), for: .normal)
            currentTimeCardView.pauseContinueButton.isEnabled = false
            currentTimeCardView.startStopButton.setBackgroundImage(UIImage(systemName: Constants.ImageName.startButton), for: .normal)
            currentTimeCardView.startStopButton.isEnabled = true

        case .ongoing:
            navigationItem.title = CommonFormatters.shared.shortDayDateFormatter.string(from: timeCard!.startDate)
            breakDurationTimer?.invalidate()
            breakDurationTimer = nil
            if !(timeCardDurationTimer?.isValid ?? false) {
                setupTimeCardDurationTimer()
            }
            currentTimeCardView.breakLabel.isHidden = true
            currentTimeCardView.pauseContinueButton.setBackgroundImage(UIImage(systemName: Constants.ImageName.pauseButton), for: .normal)
            currentTimeCardView.pauseContinueButton.isEnabled = true
            currentTimeCardView.startStopButton.setBackgroundImage(UIImage(systemName: Constants.ImageName.stopButton), for: .normal)
            currentTimeCardView.startStopButton.isEnabled = true

        case .onABreak:
            navigationItem.title = CommonFormatters.shared.shortDayDateFormatter.string(from: timeCard!.startDate)
            timeCardDurationTimer?.invalidate()
            timeCardDurationTimer = nil
            if !(breakDurationTimer?.isValid ?? false) {
                setupBreakDurationTimer()
            }
            if let timeCard = timeCard, let durationText = CommonFormatters.shared.durationDateComponentsFormatter.string(from: timeCard.duration) {
                currentTimeCardView.durationLabel.text = durationText
            }
            currentTimeCardView.breakLabel.isHidden = false
            currentTimeCardView.pauseContinueButton.setBackgroundImage(UIImage(systemName: Constants.ImageName.continueButton), for: .normal)
            currentTimeCardView.pauseContinueButton.isEnabled = true
            currentTimeCardView.startStopButton.setBackgroundImage(UIImage(systemName: Constants.ImageName.stopButton), for: .normal)
            currentTimeCardView.startStopButton.isEnabled = false

        case .finished:
            navigationItem.title = CommonFormatters.shared.shortDayDateFormatter.string(from: timeCard!.startDate)
            timeCardDurationTimer?.invalidate()
            timeCardDurationTimer = nil
            breakDurationTimer?.invalidate()
            breakDurationTimer = nil
            if let timeCard = timeCard, let durationText = CommonFormatters.shared.durationDateComponentsFormatter.string(from: timeCard.duration) {
                currentTimeCardView.durationLabel.text = durationText
            }
            currentTimeCardView.breakLabel.isHidden = true
            currentTimeCardView.pauseContinueButton.setBackgroundImage(UIImage(systemName: Constants.ImageName.pauseButton), for: .normal)
            currentTimeCardView.pauseContinueButton.isEnabled = false
            currentTimeCardView.startStopButton.setBackgroundImage(UIImage(systemName: Constants.ImageName.stopButton), for: .normal)
            currentTimeCardView.startStopButton.isEnabled = false
        }

        currentTimeCardView.tableView.reloadData()
    }
    // swiftlint:enable function_body_length

    func setupTimeCardDurationTimer() {
        timeCardDurationTimer = Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true) { [weak self] _ in
            guard let self = self, let timeCard = self.timeCard else { return }

            let durationText = CommonFormatters.shared.durationDateComponentsFormatter.string(from: timeCard.duration) ?? Constants.TimeCardDetails.durationPlaceholder

            DispatchQueue.main.async { [weak self, durationText] in
                guard let self = self else { return }
                self.currentTimeCardView.durationLabel.text = durationText
            }
        }
    }

    func setupBreakDurationTimer() {
        guard let currentBreak = try? timeCard?.currentBreak() else {
            return
        }

        breakDurationTimer = Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true) { [weak self, currentBreak] _ in
            guard let self = self else { return }

            let durationText = CommonFormatters.shared.durationDateComponentsFormatter.string(from: currentBreak.duration) ?? Constants.TimeCardDetails.durationPlaceholder

            DispatchQueue.main.async { [weak self, durationText] in
                guard let self = self else { return }
                self.currentTimeCardView.breakLabel.text = String(format: NSLocalizedString("on a break for %@", comment: "Text indicating the duration of the current break"), durationText)
            }
        }
    }

}

// MARK: - CurrentTimeCardViewDelegate

extension CurrentTimeCardViewController: CurrentTimeCardViewDelegate {

    func currentTimeCardView(_ view: CurrentTimeCardView, didTapStartStopButton button: UIButton) {
        if let currentTimeCard = timeCard {
            do {
                try currentTimeCard.finish()
            } catch {
                print("Error when trying to finish the current time card: \(error.localizedDescription)")
            }
        } else {
            timeCard = TimeCard(start: currentDateProvider.currentDate())
        }
    }

    func currentTimeCardView(_ view: CurrentTimeCardView, didTapPauseContinueButton button: UIButton) {
        guard let currentTimeCard = timeCard else {
            return
        }

        if currentTimeCard.state == .ongoing {
            do {
                try currentTimeCard.startBreak()
            } catch {
                print("Error when trying to start a break on the current time card: \(error.localizedDescription)")
            }
        } else {
            do {
                try currentTimeCard.finishBreak()
            } catch {
                print("Error when trying to finish the current break on the current time card: \(error.localizedDescription)")
            }
        }
    }

}

// MARK: - UITableViewDataSource

extension CurrentTimeCardViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        // If there are no breaks, there's only one section (for the start and end dates)
        // If there are any breaks, there's one additional section for each one
        (timeCard?.breaks.count ?? 0) + 1
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
        switch row {
        case 0:
            cell.textLabel?.text = Constants.TimeCardDetails.clockInTimeCellTitle
            if let startDate = timeCard?.startDate {
                cell.detailTextLabel?.text = CommonFormatters.shared.timeDateFormatter.string(from: startDate)
            } else {
                cell.detailTextLabel?.text = Constants.TimeCardDetails.timePlaceholder
            }
        case 1:
            cell.textLabel?.text = Constants.TimeCardDetails.clockOutTimeCellTitle
            if let endDate = timeCard?.endDate {
                cell.detailTextLabel?.text = CommonFormatters.shared.timeDateFormatter.string(from: endDate)
            } else {
                cell.detailTextLabel?.text = Constants.TimeCardDetails.timePlaceholder
            }
        default:
            assertionFailure("There are more than two rows at the first section")
        }
    }

    private func configureBreakSectionCell(_ cell: TimeCardDetailTableViewCell, forRowAt indexPath: IndexPath) {
        guard let timeCard = timeCard else {
            assertionFailure("A break section exists without an active time card")
            return
        }

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

// MARK: - TimeCardDelegate

extension CurrentTimeCardViewController: TimeCardDelegate {

    func timeCard(_ timeCard: TimeCard, didUpdateState state: TimeCard.State) {
        guard timeCard == self.timeCard else {
            assertionFailure()
            return
        }

        updateUI()
    }

}
