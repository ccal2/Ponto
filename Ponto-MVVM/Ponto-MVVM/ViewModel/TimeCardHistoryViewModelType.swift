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
    @Published var timeCardListDatasGroupedByMonth: [(key: String, value: [TimeCardListData])] = []

    // MARK: - Methods

    func fetchTimeCards() { }
    func timeCardDetailViewModel(for: TimeCardListData) -> TimeCardDetailViewModel? { fatalError("subclass should override") }

}

// MARK: - TimeCardListData

struct TimeCardListData: Hashable, Identifiable {

    // MARK: - Properties

    let id: UUID
    var dateText: String
    var durationText: String

    // MARK: - Initializers

    init(id: UUID = UUID(), dateText: String, durationText: String) {
        self.id = id
        self.dateText = dateText
        self.durationText = durationText
    }

    init(timeCard: TimeCard) {
        id = timeCard.id
        dateText = CommonFormatters.shared.mediumDayDateFormatter.string(from: timeCard.startDate)
        durationText = CommonFormatters.shared.durationDateComponentsFormatter.string(from: timeCard.duration) ?? Constants.TimeCardDetails.durationPlaceholder
    }

}
