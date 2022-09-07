//
//  TimeCardDetailViewModel.swift
//  Ponto-MVVM
//
//  Created by Carolina Cruz Agra Lopes on 29/08/22.
//

import Foundation

class TimeCardDetailViewModel: TimeCardViewModelType {

    // MARK: - Properties

    override var title: String {
        CommonFormatters.shared.longDayDateFormatter.string(from: timeCard.startDate)
    }

    override var isTitleLarge: Bool {
        false
    }

    override var clockInText: String {
        CommonFormatters.shared.timeDateFormatter.string(from: timeCard.startDate)
    }

    override var clockOutText: String {
        guard let endDate = timeCard.endDate else {
            assertionFailure("Only finished time cards should be used in a TimeCardDetailViewModel")
            return Constants.TimeCardDetails.timePlaceholder
        }

        return CommonFormatters.shared.timeDateFormatter.string(from: endDate)
    }

    override var breakList: [BreakListData] {
        timeCard.breaks.map { `break` in
            BreakListData(break: `break`)
        }
    }

    /// Model
    let timeCard: TimeCard

    /// Timers
    private var timeCardDurationTimer: Timer?
    private var breakDurationTimer: Timer?

    // MARK: - Initializers

    init(timeCard: TimeCard) {
        self.timeCard = timeCard
        super.init()

        self.durationText = CommonFormatters.shared.durationDateComponentsFormatter.string(from: timeCard.duration) ?? Constants.TimeCardDetails.durationPlaceholder
    }

    // MARK: - Methods

    override func fetchTimeCard() { }

}
