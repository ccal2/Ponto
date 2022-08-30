//
//  TimeCardHistoryViewModelType.swift
//  Ponto-MVVM
//
//  Created by Carolina Cruz Agra Lopes on 29/08/22.
//

import Combine
import Foundation

class TimeCardHistoryViewModelType: ObservableObject {

    // MARK: - Properties

    var title: String { fatalError("subclass should override") }
    @Published var timeCardsGroupedByMonth: [(key: String, value: [TimeCardListData])] = []

    // MARK: - Methods

    func fetchTimeCards() { }

}

// MARK: - TimeCardListData

struct TimeCardListData: Hashable {

    // MARK: - Properties

    var dateText: String
    var durationText: String

    // MARK: - Initializers

    init(dateText: String, durationText: String) {
        self.dateText = dateText
        self.durationText = durationText
    }

    init(timeCard: TimeCard) {
        dateText = CommonFormatters.shared.mediumDayDateFormatter.string(from: timeCard.startDate)
        durationText = CommonFormatters.shared.durationDateComponentsFormatter.string(from: timeCard.duration) ?? Constants.TimeCardDetails.durationPlaceholder
    }

}
