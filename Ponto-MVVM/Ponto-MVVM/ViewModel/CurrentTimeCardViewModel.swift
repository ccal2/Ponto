//
//  CurrentTimeCardViewModel.swift
//  Ponto-MVVM
//
//  Created by Carolina Cruz Agra Lopes on 25/07/22.
//

import Foundation

class CurrentTimeCardViewModel: TimeCardViewModel {

    // MARK: - Properties

    override var title: String {
        guard let timeCard = timeCard else {
            return CommonFormatters.shared.shortDayDateFormatter.string(from: currentDateProvider.currentDate())
        }

        return CommonFormatters.shared.shortDayDateFormatter.string(from: timeCard.startDate)
    }

    override var pauseResumeButtonImageName: String? {
        (timeCard?.state == .onABreak) ? Constants.ImageName.resumeButton : Constants.ImageName.pauseButton
    }

    override var startStopButtonImageName: String? {
        (timeCard == nil) ? Constants.ImageName.startButton : Constants.ImageName.stopButton
    }

    override var isPauseResumeButtonDisabled: Bool {
        let disabledStates: [TimeCard.State?] = [nil, .finished]
        return disabledStates.contains(timeCard?.state)
    }

    override var isStartStopButtonDisabled: Bool {
        let disabledStates: [TimeCard.State?] = [.onABreak, .finished]
        return disabledStates.contains(timeCard?.state)
    }

    override var clockInText: String {
        guard let timeCard = timeCard else {
            return Constants.TimeCardDetails.timePlaceholder
        }

        return CommonFormatters.shared.timeDateFormatter.string(from: timeCard.startDate)
    }

    override var clockOutText: String {
        guard let endDate = timeCard?.endDate else {
            return Constants.TimeCardDetails.timePlaceholder
        }

        return CommonFormatters.shared.timeDateFormatter.string(from: endDate)
    }

    override var breakList: [BreakListData] {
        timeCard?.breaks.map { `break` in
            BreakListData(break: `break`)
        } ?? []
    }

    /// Model
    var timeCard: TimeCard? {
        didSet {
            updateDurationTexts()
        }
    }

    /// Injected dependencies
    private let timeCardRepository: TimeCardRepository
    private var currentDateProvider: CurrentDateProvider

    /// Timers
    private var timeCardDurationTimer: Timer?
    private var breakDurationTimer: Timer?

    // MARK: - Initializers

    init(timeCardRepository: TimeCardRepository = LocalTimeCardRepository.shared, currentDateProvider: CurrentDateProvider = DateProvider.shared) {
        self.timeCardRepository = timeCardRepository
        self.currentDateProvider = currentDateProvider
    }

    // MARK: - Methods

    override func fetchTimeCard() {
        timeCardRepository.get(for: currentDateProvider.currentDate()) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case let .success(timeCard):
                self.timeCard = timeCard
            case let .failure(error):
                print("Error when trying to load the current time card: \(error.localizedDescription)")
            }
        }
    }

    override func pauseOrResumeTimeCard() {
        guard timeCard != nil else {
            return
        }

        if timeCard?.state == .ongoing {
            do {
                try timeCard?.startBreak()
            } catch {
                print("Error when trying to start a break on the current time card: \(error.localizedDescription)")
            }
        } else {
            do {
                try timeCard?.finishBreak()
            } catch {
                print("Error when trying to finish the current break on the current time card: \(error.localizedDescription)")
            }
        }
    }

    override func startOrStopTimeCard() {
        if timeCard != nil {
            do {
                try timeCard?.finish()
            } catch {
                print("Error when trying to finish the current time card: \(error.localizedDescription)")
            }
        } else {
            timeCard = TimeCard(start: currentDateProvider.currentDate())
        }
    }

    // MARK: - Helpers

    private func updateDurationTexts() {
        guard let timeCard = timeCard else {
            return
        }
        durationText = durationText(for: timeCard)

        switch timeCard.state {
        case .ongoing:
            breakDurationTimer?.invalidate()
            breakDurationTimer = nil
            breakText = nil
            setupTimeCardDurationTimer()
        case .onABreak:
            timeCardDurationTimer?.invalidate()
            timeCardDurationTimer = nil
            setupBreakDurationTimer()
        case .finished:
            timeCardDurationTimer?.invalidate()
            timeCardDurationTimer = nil
            breakDurationTimer?.invalidate()
            breakDurationTimer = nil
        }
    }

    private func setupTimeCardDurationTimer() {
        timeCardDurationTimer = Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true) { [weak self] _ in
            guard let self = self, let timeCard = self.timeCard else { return }

            self.durationText = self.durationText(for: timeCard)
        }
    }

    private func setupBreakDurationTimer() {
        breakDurationTimer = Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            guard let timeCard = self.timeCard,
                  let currentBreakIndex = try? timeCard.currentBreakIndex(),
                  let formattedText = CommonFormatters.shared.durationDateComponentsFormatter.string(from: timeCard.breaks[currentBreakIndex].duration) else {
                self.breakText = nil
                return
            }

            self.breakText = String(format: NSLocalizedString("on a break for %@", comment: "Text indicating the duration of the current break"), formattedText)
        }
    }

    private func durationText(for timeCard: TimeCard) -> String {
        CommonFormatters.shared.durationDateComponentsFormatter.string(from: timeCard.duration) ?? Constants.TimeCardDetails.durationPlaceholder
    }

}
