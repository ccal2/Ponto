//
//  TimeCardHistoryViewModel.swift
//  Ponto-MVVM
//
//  Created by Carolina Cruz Agra Lopes on 29/08/22.
//

import Foundation

class TimeCardHistoryViewModel: TimeCardHistoryViewModelType {

    // MARK: - Properties

    override var title: String {
        Constants.TimeCardHistory.screenTitle
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

    override func fetchTimeCards() {
        timeCardRepository.listFinished(limitedBy: nil) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case let .success(timeCards):
                self.timeCardsGroupedByMonth = Dictionary(grouping: timeCards) { timeCard in
                    timeCard.startDate.monthComponents
                }.mapValues { timeCards in
                    timeCards.map { timeCard in
                        TimeCardListData(timeCard: timeCard)
                    }
                }.sorted { lhs, rhs in
                    guard let lhsYear = lhs.key.year,
                          let lhsMonth = lhs.key.month,
                          let rhsYear = rhs.key.year,
                          let rhsMonth = rhs.key.month else {
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
                }.map { element in
                    let sectionTitle: String
                    if let monthDate = element.key.date {
                        sectionTitle = CommonFormatters.shared.monthDateFormatter.string(from: monthDate)
                    } else {
                        assertionFailure("Failed to get date from components")
                        sectionTitle = ""
                    }

                    return (key: sectionTitle, value: element.value)
                }
            case let .failure(error):
                print("Error when trying to load time cards: \(error.localizedDescription)")
            }
        }
    }

}
